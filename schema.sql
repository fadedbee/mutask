
DROP TABLE task_switches;
DROP TABLE tasks;
DROP TABLE purchase_orders;
DROP TABLE org_emails;
DROP TABLE org_msgs;
DROP TABLE email_msgs;
DROP TABLE orgs;
DROP TABLE token_cookies;
DROP TABLE tokens;
DROP TABLE emails;

CREATE TABLE emails (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  email VARCHAR(255) UNIQUE NOT NULL
);

CREATE OR REPLACE FUNCTION random_string(length integer) RETURNS text AS
$$
declare
  chars text[] := '{0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  result text := '';
  i integer := 0;
begin
  if length < 0 then
    raise exception 'Given length cannot be less than 0';
  end if;
  for i in 1..length loop
    result := result || chars[1+random()*(array_length(chars, 1)-1)];
  end loop;
  return result;
end;
$$ language plpgsql;

CREATE TABLE tokens (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  email VARCHAR(255) REFERENCES emails(email),
  token VARCHAR(20) UNIQUE NOT NULL DEFAULT random_string(20)
);

CREATE TABLE token_cookies (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  token VARCHAR(20) UNIQUE REFERENCES tokens(token),
  cookie VARCHAR(40) UNIQUE NOT NULL DEFAULT random_string(40)
);

CREATE TABLE orgs (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  org VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE org_emails (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  org VARCHAR(255) REFERENCES orgs(org),
  email VARCHAR(255) REFERENCES emails(email)
);

CREATE TABLE org_msgs (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  email VARCHAR(255) REFERENCES emails(email),
  text VARCHAR(255) NOT NULL
);

CREATE TABLE email_msgs (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  org VARCHAR(255) REFERENCES orgs(org),
  text VARCHAR(255) NOT NULL
);

CREATE TABLE purchase_orders (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  purchase_order VARCHAR(255) UNIQUE NOT NULL,
  org VARCHAR(255) REFERENCES orgs(org)
);

CREATE TABLE tasks (
  task_id SERIAL PRIMARY KEY,
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  parent INTEGER REFERENCES tasks(task_id),
  org VARCHAR(255) REFERENCES orgs(org),
  text VARCHAR(255) NOT NULL
);

CREATE TABLE task_switches (
  ts TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  created_by VARCHAR(255) REFERENCES emails(email),
  task_id INTEGER REFERENCES tasks
);

