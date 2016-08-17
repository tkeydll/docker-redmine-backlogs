FROM redmine:3.3

WORKDIR /usr/src/redmine

# Init redmine.
RUN /docker-entrypoint.sh rails

# Install require components.
RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc \
      make \
      g++ \
	&& rm -rf /var/lib/apt/lists/*

RUN bundle install --without development test \
    && gem install holidays --version 1.0.3 \
    && gem install holidays

# Install backlogs plugins.
RUN cd ./plugins \ 
    && git clone https://github.com/tkeydll/redmine_backlogs.git \
    && cd ./redmine_backlogs \
    && git checkout feature/redmine3

RUN export RAILS_ENV=production \
    && bundle install --without development test

RUN bundle exec rake db:migrate \
    && bundle exec rake tmp:cache:clear \
    && bundle exec rake tmp:sessions:clear

# RUN bundle exec rake redmine:backlogs:install
