"use strict"

const express = require('express');
const nodemailer = require('nodemailer');

const pg = require('pg');
var config = {
  user: process.env.DB_USER,
  database: process.env.DB_NAME,
  password: process.env.DB_PASS,
  host: '127.0.0.1',
  port: 5432,
  max: 10,
  idleTimeoutMillis: 30000
};
const db = new pg.Pool(config);
db.connect(function(err, ret) {
  if (err) return console.error(err);
  console.info('ret:', ret);
});

var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'muTask' });
});

/*
 * This page generates a new token and emails it.
 */
router.post('/token', function(req, res, next) {
  const email = req.body.email; // TODO: validate email
  console.log('email:', email);

  db.query({
    name: 'insert_email',
    text: 'INSERT INTO emails(created_by, email) VALUES($1, $2);',
    values: [email, email]
  }, function (err, info) {
    // error expected, if email has been seen before
    console.log('err:', err, 'res:', info);

    db.query({
      name: 'insert_token',
      text: 'INSERT INTO tokens(created_by, email) VALUES($1, $2) RETURNING token;',
      values: [email, email]
    }, function (err, info) {
      console.log('err:', err, 'res:', info); // TODO: handle error
      const token = info.rows[0].token;

      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS
        }
      });

      const mailOptions = {
        from: process.env.EMAIL_FROM,
        to: email,
        subject: 'test',
        html: '<p><a href="http://localhost:3000/token/' + token + '">' + token + '</p>',
        text: 'your text here'
      };

      transporter.sendMail(mailOptions, function (err, info) {
        if (err) {
          console.error(err);
        } else {
          console.info(info);
        }
        res.send('email sent');
      });
    });
  });
});

/*
 * This page makes a cookie for the token, and then redirects.
 */
router.get('/token/:token', function(req, res, next) {
  const token = req.params.token;
  console.log('token:', token);

  db.query({
    name: 'insert_token_cookie',
    text: 'INSERT INTO token_cookies(created_by, token) VALUES((SELECT email FROM tokens WHERE token = $1), $2) RETURNING cookie;',
    values: [token, token]
  }, function (err, info) {
    // error expected, if email has been seen before
    console.log('err:', err, 'res:', info);
    const cookie = info.rows[0].cookie;
    res.send('cookie: ' + cookie);
  });
});

module.exports = router;

