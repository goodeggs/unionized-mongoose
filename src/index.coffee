unionized = require 'unionized/src/unionized'
faker = require 'faker'
Promise = require 'bluebird'

buildFactoryFromSchema = (schema, mongoose) ->
  {ObjectId, String, Number, DocumentArray} = mongoose.SchemaTypes
  definition = @
  embedArray = Promise.promisify(definition.embedArray, definition)
  promises = []

  schema.eachPath (pathName, schemaType) ->
    switch
      when schemaType instanceof ObjectId
        definition.set pathName, new mongoose.Types.ObjectId()
      when schemaType instanceof String and pathName is 'name'
        definition.set pathName, faker.Name.findName()
      when schemaType instanceof String
        definition.set pathName, faker.Lorem.words().join ' '
      when schemaType instanceof Number
        definition.set pathName, faker.random.number 100
      when schemaType instanceof DocumentArray
        promises.push embedArray pathName, 2, unionized.define (callback) ->
          buildFactoryFromSchema.call(@, schemaType.schema, mongoose).nodeify(callback)
  Promise.all promises

module.exports = mongooseFactory = (Model) ->
  unionized.define Model, (callback) ->
    mongoose = Model.db.base
    buildFactoryFromSchema.call(@, Model.schema, mongoose).nodeify(callback)
