
# lamjet

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](https://github.com/nayutaya/lamjet/blob/master/LICENSE.txt)
[![npm](https://img.shields.io/npm/v/lamjet.svg?style=flat-square)](https://www.npmjs.com/package/lamjet)
[![Circle CI](https://img.shields.io/circleci/project/nayutaya/lamjet.svg?style=flat-square)](https://circleci.com/gh/nayutaya/lamjet)
[![Dependency Status](https://img.shields.io/david/nayutaya/lamjet.svg?style=flat-square)](https://david-dm.org/nayutaya/lamjet)
[![devDependency Status](https://img.shields.io/david/dev/nayutaya/lamjet.svg?style=flat-square)](https://david-dm.org/nayutaya/lamjet#info=devDependencies)

## Overview

[AWS Lambda](https://aws.amazon.com/lambda/) + [Jasmine](http://jasmine.github.io/) + [CoffeeScript](http://coffeescript.org/) = Lamjet!

## Installation

```
$ npm install -g lamjet
```

## Usage

### 1. Create new Lambda function

```
$ cd /your/project/path
$ mkdir your-function-name
$ cd your-function-name
$ lamjet init
$ npm install
$ gulp  # or: npm test
```

### 2. Edit configuration

```
$ vim aws-lambda-config.js
```

### 3. Deploy function to AWS Lambda

```
# Setup AWS credentials
$ export AWS_ACCESS_KEY_ID=...
$ export AWS_SECRET_ACCESS_KEY=...

$ gulp deploy  # or: npm run-script deploy
```

## License

MIT License
