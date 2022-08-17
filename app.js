'use strict';

const path = require('path');
const AutoLoad = require('@fastify/autoload');
const session = require('@fastify/session');
const cookie = require('@fastify/cookie');
const { env } = require('process');
const { multer } = require('./config/multerSettings');
const MySQLStore = require('connect-mysql')(session);
const AJV = require('ajv');
const customAjv = new AJV({ removeAddtional: false });

module.exports = async function (fastify, opts) {
  const MySQLConnectOptions = {
    config: {
      host: env.DB_HOST,
      user: env.DB_USER,
      password: env.DB_PASS,
      database: env.DB_DB,
    },
  };

  fastify.setSchemaController(customAjv);

  fastify.register(require('@fastify/mysql'), MySQLConnectOptions.config);

  fastify.register(cookie);
  fastify.register(session, {
    secret: env['SESSION_SECRET'],
    store: new MySQLStore(MySQLConnectOptions),
    saveUninitialized: false,
    cookie: {
      httpOnly: false,
      secure: false,
      maxAge: 1000 * 60 * 60 * 24 * 2,
      expires: 1000 * 60 * 60 * 24 * 2,
    },
  });

  fastify.register(require('@fastify/cors'), {
    origin: [
      'http://127.0.0.1:3000',
      'http://localhost:3000',
      '127.0.0.1:3000',
      'localhost:3000',
      'http://localhost:3000',
    ],
    // methods: '*',
    credentials: true,
    // allowedHeaders: ['Content-Type'],
    // "preflightContinue": true,
    // "optionsSuccessStatus": 204
  });

  fastify.register(multer.contentParser);
  global.appRoot = path.resolve(__dirname);
  global.fastify = fastify;

  fastify.register(require('@fastify/static'), {
    root: path.join(__dirname, 'uploads'),
    prefix: '/public/',
  });

  // Do not touch the following lines

  // This loads all plugins defined in plugins
  // those should be support plugins that are reused
  // through your application
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'plugins'),
    options: Object.assign({ prefix: '/api' }, opts),
  });

  // This loads all plugins defined in routes
  // define your routes in one of these
  fastify.register(AutoLoad, {
    dir: path.join(__dirname, 'routes'),
    routeParams: true,
    options: Object.assign({ prefix: '/api' }, opts),
  });
};
