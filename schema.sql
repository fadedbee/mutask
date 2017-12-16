CREATE TABLE emails (
  ts
  creator
  email
)

CREATE TABLE handles (
  ts
  creator
  email
  handle
)

CREATE TABLE teams (
  ts
  creator
  team
)

CREATE TABLE email_teams (
  ts
  creator
  email
  team
)

CREATE TABLE msgs (
  ts
  creator
  dst -- either team or email
  text
)

CREATE TABLE tasks (
  ts
  creator

)