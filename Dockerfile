FROM ruby:2.5.0

RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    mysql-client \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /blend
WORKDIR /blend

RUN mkdir -p tmp/sockets

ADD Gemfile /blend/Gemfile
ADD Gemfile.lock /blend/Gemfile.lock
RUN bundle install
ADD . /blend

EXPOSE 3000