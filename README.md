[![Build Status](https://travis-ci.org/dwyl/best-evidence.svg?branch=master)](https://travis-ci.org/dwyl/best-evidence)
[![codecov](https://codecov.io/gh/dwyl/best-evidence/branch/master/graph/badge.svg)](https://codecov.io/gh/dwyl/best-evidence)
# BestEvidence

Before contributing to the project, please read our contributing guide here: https://github.com/dwyl/contributing

# Introduction

BestEvidence (BE) is an open source project commissioned by City, University of
London. The purpose is to create an application that can be used to search for
scientific evidence to aid a user in following the principles of evidence-based practice.
The primary audience is medical professionals/students, but the app is open to all,
including lay members of the public.

## Live App Links

BestEvidence can be found at: https://www.bestevidence.info/

This URL corresponds to the production app on Heroku: https://best-evidence-app.herokuapp.com/

There is also a staging app to test features prior to production: https://best-evidence-staging.herokuapp.com/


## Technologies Used
The project utilises a number of technologies, listed here:

  | Technology | Use in Project | dwyl Open Source Tutorial |
  | - | - | - |
  |[Elixir](https://elixir-lang.org/) | Language | https://github.com/dwyl/learn-elixir |
  | [Phoenix](http://www.phoenixframework.org/) | Framework | https://github.com/dwyl/learn-phoenix-framework |
  | [Tachyons](https://tachyons-bootstrap.dwyl.com/) | Styling | https://github.com/dwyl/learn-tachyons |
  | [JavaScript](https://developer.mozilla.org/bm/docs/Web/JavaScript) | Front End | https://github.com/dwyl/learn-javascript |
  | [Node.js](https://nodejs.org/en/) | [Phoenix Dependency](https://hexdocs.pm/phoenix/installation.html#node-js-5-0-0) | https://github.com/dwyl/learn-node-js-by-example |
  | [PostgreSQL](https://www.postgresql.org/) | Database | https://github.com/dwyl/learn-postgresql |
  | [Heroku](https://heroku.com) | Hosting | https://github.com/dwyl/learn-heroku |

## Setup

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`
  * Visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check the deployment guide](http://www.phoenixframework.org/docs/deployment).

## Features

### In-app messaging
This functionality allows for **one way communication** from administrators to users
_by design_.

Although design solutions were presented for a 'chat' style of UI
which would allow users to reply and interact with administrators, it was noted
that in these early stages of the application there simply wouldn't be enough
resources for BE admins to keep up with full in-app two way communications.

Administrators can communicate with:
+ **All users:** This will be used to communicate things like new features or
important news
  + ***Super admins*** are the only ones who can message _all_ users
  + ***Client admins*** can only message the [users who 'belong' to this client](https://github.com/dwyl/bestevidence/issues/298)
+ **Individual users:** This will be used to alert users of things like if they
have inadvertently breached patient confidentiality or to lend individualised support
  + All user email addresses will [continue to be encrypted](https://github.com/dwyl/bestevidence/issues/247)
  and no user _names_ are collected, so this will be via user ID

Users will be able to see that they have new messages by a small red dot next
to the `Messages` item in the navigation.
In their Messages screen, they will also be presented with a banner message
to let them know _how_ to contact the BE team should they need to.
  
#### In-App messaging preliminary designs

**Admin user flows**  
This flow begins on the administrator's `Messages` screen, allowing them to pick
a _specific individual_ to send a message to.
<img width="494" alt="screen shot 2018-06-19 at 02 14 52" src="https://user-images.githubusercontent.com/4185328/41570579-61ea26c8-7367-11e8-8dab-59d6ffc6a4bd.png">

If the admin is to select 'Send to all' in the top right of the screen, they would
go through the following flow instead:
<img width="368" alt="screen shot 2018-06-19 at 02 22 33" src="https://user-images.githubusercontent.com/4185328/41570766-01117710-7368-11e8-9e14-2d6beb88a860.png">

**User's `Messages` screen**
<img width="206" alt="screen shot 2018-06-19 at 02 26 39" src="https://user-images.githubusercontent.com/4185328/41570877-7c5a390c-7368-11e8-98d0-c5d30d74f598.png">



## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
  * Tachyons Bootstrap: https://tachyons-bootstrap.dwyl.com/
