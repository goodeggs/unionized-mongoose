mongoose = require 'mongoose'
unionized = require 'unionized/src/unionized'
faker = require 'faker'
Promise = require 'bluebird'

buildFactoryFromSchema = (schema) ->
  definition = @
  embedArray = Promise.promisify(definition.embedArray, definition)
  promises = []

  schema.eachPath (pathName, schemaType) ->
    switch
      when schemaType instanceof mongoose.SchemaTypes.String and pathName is 'name'
        definition.set pathName, faker.Name.findName()
      when schemaType instanceof mongoose.SchemaTypes.String
        definition.set pathName, faker.Lorem.words().join ' '
      when schemaType instanceof mongoose.SchemaTypes.Number
        definition.set pathName, faker.random.number 100
      when schemaType instanceof mongoose.SchemaTypes.DocumentArray
        promises.push embedArray pathName, 2, unionized.define (callback) ->
          buildFactoryFromSchema.call(@, schemaType.schema).nodeify(callback)
  Promise.all promises

module.exports = mongooseFactory = (model) ->
  unionized.define model, (callback) ->
    buildFactoryFromSchema.call(@, model.schema).nodeify(callback)
