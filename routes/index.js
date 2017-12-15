var express = require('express');

var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  res.redirect('/session/' + new_id());
});

router.get('/session/:sid', function(req, res, next) {
  res.render('index', { title: 'Express', sid: req.params.sid });
});

module.exports = router;

var crypto = require('crypto');

function new_id() {
  var id = '';
  while (id.length < 8) {
    var num = 62;
    while (num > 61) {
      num = crypto.randomBytes(1)[0];
    }
    id += "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"[num];
  }
  return id;
}
