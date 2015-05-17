DotNotationObjectDefinition = require 'unionized/lib/dot_notation_object_definition'
Factory = require 'unionized/lib/factory'
ObjectInstance = require 'unionized/lib/object_instance'
Promise = require 'bluebird'
faker = require 'faker'
unionized = require 'unionized'

buildDefinitionObjectFromSchema = (schema, mongoose) ->
  definitionObject = {}
  schema.eachPath (pathName, schemaType) ->
    switch
      when schemaType instanceof mongoose.SchemaTypes.DocumentArray
        definitionObject[pathName] = unionized.array buildDefinitionObjectFromSchema(schemaType.schema, mongoose)

      when pathName is '_id'
        definitionObject[pathName] = -> new mongoose.Types.ObjectId()

      when not schemaType.isRequired then return

      when schemaType.defaultValue? and typeof schemaType.defaultValue isnt 'function'
        definitionObject[pathName] = schemaType.defaultValue

      when schemaType.enumValues?.length > 0
        definitionObject[pathName] = -> faker.random.array_element schemaType.enumValues

      when schemaType instanceof mongoose.SchemaTypes.ObjectId
        definitionObject[pathName] = -> new mongoose.Types.ObjectId()

      when schemaType instanceof mongoose.SchemaTypes.Boolean
        definitionObject[pathName] = -> faker.random.array_element [true, false]

      when schemaType instanceof mongoose.SchemaTypes.Date
        definitionObject[pathName] = -> faker.date.between(new Date('2013-01-01'), new Date('2014-01-01'))

      when schemaType instanceof mongoose.SchemaTypes.String
        definitionObject[pathName] = -> faker.lorem.words().join ' '

      when schemaType instanceof mongoose.SchemaTypes.Number
        definitionObject[pathName] = -> faker.random.number 100

  definitionObject

class MongooseDocumentInstance extends ObjectInstance
  constructor: (@Model) -> super()
  toObject: -> new @Model(super())

class MongooseDocumentDefinition extends DotNotationObjectDefinition
  initialize: ->
    @Model = @args[1]
    super()
  stage: -> super(new MongooseDocumentInstance(@Model))
  stageAsync: -> super(new MongooseDocumentInstance(@Model))

Factory::mongooseFactory = (Model) ->
  mongoose = Model.db.base
  unionized.factory new MongooseDocumentDefinition(buildDefinitionObjectFromSchema(Model.schema, mongoose), Model)

module.exports = unionized
