# cppize_aas

[cppize](https://github.com/unn4m3d/cppize) as a service

## Building and deploying on Heroku

Compilation step requires about 2GB of RAM, so it's recommended to build it on local machine :
### First build:
```sh
git clone https://github.com/unn4m3d/cppize-aas
cd cppize-aas
# This will automatically build and deploy this app
crystal ./build_heroku.cr -- --create <appname> <folder> # For example, appname would be cppize-example, and folder would be ../heroku_dist
```

### Next builds:
```sh
cd path/to/cppize-aas
crystal ./build_heroku.cr -- <folder>
```

Provide `--buildpack` option to `build_heroku.cr` to use another buildpack

## Contributing

1. Fork it ( https://github.com/unn4m3d/cppize-aas/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [unn4m3d](https://github.com/unn4m3d) - creator, maintainer
