# LSA Movers Classrooms
![](https://img.shields.io/badge/Ruby%20Version-4.0.1-red) ![](https://img.shields.io/badge/Rails%20Version-8.1.3-red) ![](https://img.shields.io/badge/Postgresql%20Version-14.10-red)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

The finished application allows admins to set up buildings and rooms for ROVERs to check, monitor rooms status, run reports, and keep rooms’ resources up to date. ROVERs should be able to log in on phones, pick rooms, fill out the rooms’ form, and create TDX tickets for any problems. 

## Getting Started (Mac)

### Prerequisites
- postgresql (correct version and running without errors)
- This application uses University of Michigan Shibboleth + DUO authentication

To get a local copy up and running clone the repo, navigate to the local instance and start the application
```
git clone git@github.com:lsa-mis/room_ready.git
cd room_ready
bundle
bin/rails db:create
bin/rails db:migrate
bin/dev
```

  ## Authentication
  - Omniauth-SAML
    - Shibboleth + DUO
    - Devise

## Support / Questions
  Please email the [LSA W&ADS Rails Team](mailto:lsa-was-rails-devs@umich.edu)
