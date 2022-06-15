## Rails
Dockerfileとdocker-compose.ymlを用意

```
$ vim Gemfile
    source 'https://rubygems.org'
    gem 'rails', '7.0.3'

$ touch Gemfile.lock
$ docker-compose run web rails new . --force --no-deps --database=postgresql --skip-bundle
$ docker-compose build
```

`config/database.yml`を編集

```
$ docker-compose up
```

CF. https://qiita.com/daichi41/items/dfea6195cbb7b24f3419

## ECR 
CF. https://dev.classmethod.jp/articles/githubactions-ecs-fargate-cicd-beginner/
