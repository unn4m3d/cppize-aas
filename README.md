# cppize_aas

[cppize](https://github.com/unn4m3d/cppize) as a service

## Building and deploying on Heroku

Compilation step requires about 2GB of RAM, so it's recommended to build it on local machine :
```sh
mkdir heroku_distr
git clone https://github.com/unn4m3d/cppize-aas
cd heroku_distr
git init
# build script's --create option is broken, so create heroku app manually
heroku create --buildpack "https://github.com/crystal-lang/heroku-buildpack-crystal.git" <appname>
cd ../cppize-aas
crystal ./build-heroku.cr -- ../heroku_distr # This will automatically deploy your app.
```

## Contributing

1. Fork it ( https://github.com/unn4m3d/cppize-aas/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [unn4m3d](https://github.com/unn4m3d) - creator, maintainer
