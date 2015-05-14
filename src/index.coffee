unionized = require 'unionized'
faker = require 'faker'
Promise = require 'bluebird'

buildFactoryFromSchema = (schema, mongoose) ->
  {ObjectId, DocumentArray} = mongoose.SchemaTypes
  definition = @
  embedArray = Promise.promisify(definition.embedArray, definition)
  promises = []

  schema.eachPath (pathName, schemaType) ->
    switch
      when schemaType instanceof DocumentArray
        promises.push embedArray pathName, 2, unionized.define (callback) ->
          buildFactoryFromSchema.call(@, schemaType.schema, mongoose).nodeify(callback)

      when pathName is '_id'
        definition.set pathName, new mongoose.Types.ObjectId()

      when not schemaType.isRequired then return

      when schemaType.defaultValue? and typeof schemaType.defaultValue isnt 'function'
        definition.set pathName, schemaType.defaultValue

      when schemaType.enumValues?.length > 0
        definition.set pathName, faker.random.array_element schemaType.enumValues

      when schemaType instanceof ObjectId
        definition.set pathName, new mongoose.Types.ObjectId()

      when schemaType instanceof mongoose.SchemaTypes.Boolean
        definition.set pathName, faker.random.array_element [true, false]

      when schemaType instanceof mongoose.SchemaTypes.Date
        definition.set pathName, faker.date.between(new Date('2013-01-01'), new Date('2014-01-01'))

      when schemaType instanceof mongoose.SchemaTypes.String
        definition.set pathName, faker.lorem.words().join ' '

      when schemaType instanceof mongoose.SchemaTypes.Number
        definition.set pathName, faker.random.number 100

  Promise.all promises

#
# mongooseFactory(name, Model)
# or
# mongooseFactory(Model)
#
module.exports = mongooseFactory = (args...) ->
  Model = args.pop()
  name = args.pop() or Model.modelName.toLowerCase()

  unionized.define name, Model, (callback) ->
    mongoose = Model.db.base
    buildFactoryFromSchema.call(@, Model.schema, mongoose).nodeify(callback)
