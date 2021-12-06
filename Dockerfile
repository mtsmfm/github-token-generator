FROM ruby:3

RUN mkdir /app
WORKDIR /app
COPY Gemfile /app
COPY Gemfile.lock /app
RUN bundle install

COPY app.rb /app

ENV PORT=3000
ENV RACK_ENV=production

ENTRYPOINT ["ruby", "app.rb"]
