FROM ruby:2.3.1
RUN mkdir /testgrpc
WORKDIR /testgrpc
ADD Gemfile /testgrpc/Gemfile
#ADD Gemfile.lock /testgrpc/Gemfile.lock
ADD testgrpc.gemspec /testgrpc/testgrpc.gemspec
RUN bundle install
ADD . /testgrpc
