unionized = require 'unionized/src/unionized'
faker = require 'faker'
Promise = require 'bluebird'

buildFactoryFromSchema = (schema, types) ->
  definition = @
  embedArray = Promise.promisify(definition.embedArray, definition)
  promises = []

  schema.eachPath (pathName, schemaType) ->
    switch
      when schemaType instanceof types.String and pathName is 'name'
        definition.set pathName, faker.Name.findName()
      when schemaType instanceof types.String
        definition.set pathName, faker.Lorem.words().join ' '
      when schemaType instanceof types.Number
        definition.set pathName, faker.random.number 100
      when schemaType instanceof types.DocumentArray
        promises.push embedArray pathName, 2, unionized.define (callback) ->
          buildFactoryFromSchema.call(@, schemaType.schema, types).nodeify(callback)
  Promise.all promises

module.exports = mongooseFactory = (Model) ->
  unionized.define Model, (callback) ->
    mongoose = Model.db.base
    buildFactoryFromSchema.call(@, Model.schema, mongoose.SchemaTypes).nodeify(callback)
