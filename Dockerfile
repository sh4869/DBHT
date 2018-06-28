FROM ruby:2.5.1
ENV APP_ROOT /usr/src/app

WORKDIR ${APP_ROOT}
RUN apt-get update && apt-get install -y \
    build-essential \
    locales
COPY Gemfile ${APP_ROOT}

RUN locale-gen ja_JP.UTF-8  
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
ENV RUBYOPT -EUTF-8

RUN bundle install
COPY . ${APP_ROOT}

CMD [ "bundle", "exec", "ruby", "DBHT.rb" ]
