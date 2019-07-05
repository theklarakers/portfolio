# [Theklarakers.com - Portfolio](https://theklarakers.com/)

[![Portfolio Preview](https://raw.githubusercontent.com/theklarakers/portfolio/master/img/templates/screenshot.png)](https://github.com/theklarakers/portfolio)

**[View Live Preview](https://theklarakers.com/)**

## Download and Installation

To begin using this template with `make`:
- Run `make watch` and open `http://localhost:3000` and start developing with browserSync

To begin using this template with `NPM`:
* Clone the repo: `git clone https://github.com/theklarakers/portfolio.git`
* Run `npm install` and `npm run watch` and open `http://localhost:3000`

To begin using this template with `docker`:
* Run `docker run -p 8080:80 jvisser/theklarakers_com` and open `http://localhost:8080/`

#### Gulp Tasks

- `gulp` the default task that builds everything
- `gulp dev` browserSync opens the project in your default browser and live reloads when changes are made
- `gulp sass` compiles SCSS files into CSS
- `gulp minify-css` minifies the compiled CSS file
- `gulp minify-js` minifies the themes JS file
- `gulp copy` copies dependencies from node_modules to the vendor directory
- `gulp build` builds and copies the complete website to the build directory

## Development

Run:
- `docker build -t jvisser/theklarakers_com-dev -f Dockerfile.dev .` to build the image
- To update npm packages run `docker run -it --rm -v $PWD:/app jvisser/theklarakers_com-dev npm update`

OR:

- Run `make watch` and open `http://localhost:3000` and start developing with browserSync

### Shell

You can enter a shell to the docker node image for eventual debugging.

## Copyright and License

Copyright 2019 Jeroen Visser. Code released under the MIT license.

## Thnx
The template is based on the Start Bootstrap [Grayscale template](https://github.com/BlackrockDigital/startbootstrap-grayscale)!
