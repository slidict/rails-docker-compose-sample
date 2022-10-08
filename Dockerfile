FROM ruby:3.1.2-alpine3.16 as builder

ARG RAILS_ENV

ENV RAILS_ENV=$RAILS_ENV
ENV TZ "UTC"

RUN \
  apk add --no-cache yarn git openjdk11-jre-headless less chromium imagemagick-dev imagemagick file-dev npm && \
  apk add --no-cache build-base libffi-dev --virtual .build

RUN npm install -g npx

WORKDIR "/app"

FROM builder

COPY . .

RUN \
  bundle config --local path vendor/bundle && \
  bundle install && \
  bundle config frozen true && \
  bundle config set --local clean 'true'

RUN yarn install --check-file

RUN \
  if [ "$RAILS_ENV" != "development" -a "$RAILS_ENV" != "" ] ; then \
    apk del --purge .build; \
  fi

RUN bundle exec rails tmp:create

RUN \
  if [ "$RAILS_ENV" != "development" -a "$RAILS_ENV" != "" ] ; then \
    yarn build:css; \
    bundle exec rails assets:precompile --trace; \
  fi


CMD ["/bin/sh", "/app/entrypoint.sh"]

EXPOSE 3000
