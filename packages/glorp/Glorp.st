Smalltalk.Object subclass: #GlorpHelper
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: 'Glorp'
    category: 'Glorp-Extensions'!

Smalltalk.Object subclass: #AddingWriteStream
    instanceVariableNames: 'target '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Collections-Streams'!

AddingWriteStream comment: '
Why *can''t* you stream onto a set? Or a bag, or a SortedCollection? No good reason that I can see. This implements only a subset of stream behaviour, that which is necessary to let us build up collections where we have to "append" elements using #add: rather than #at:put: and explicit grows.

Instance Variables:
    target	<Collection>	The thing we''re streaming onto.

'!

Smalltalk.Object subclass: #CachePolicy
    instanceVariableNames: 'expiryAction numberOfElements '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

CachePolicy comment: '
A CachePolicy implements the different possible policies we might use for caching. The superclass implements the trivial policy of keeping all objects forever.

The policy also controls what we store in the cache. In general, it''s assumed to be a cache entry of some sort, and the policy is responsible for wrapping and unwrapping objects going to and from the cache. The default policy is that the objects themselves are the cache entry (saving one object per cached object in overhead).

Instance Variables:
    size	<Number>	The minimum cache size we want to use.
    expiryAction <Symbol> What to do when an object has expired. Currently hard-coded as one of #remove, #notify, #refresh, #notifyAndRemove.

'!


Smalltalk.Object subclass: #Login
    instanceVariableNames: 'database username password connectString name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #GlorpExpression
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

GlorpExpression subclass: #FunctionExpression
    instanceVariableNames: 'function base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

FunctionExpression class instanceVariableNames: 'possibleFunctions '!

FunctionExpression comment: '
This represents a database function or other modifier. For example, conversion to upper or lower case, or the ascending/descending modifier in order by clauses. At the moment it is hard-coded to to handle only the descending modifier and does not handle e.g. function arguments, functions that differ between databases, functional syntax ( as opposed to postfix). One would probably define subclasses to handle these cases, but this is the simplest thing that could possibly work for the current functionality.'!


GlorpExpression subclass: #ConstantExpression
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Smalltalk.Object subclass: #ObjectTransaction
    instanceVariableNames: 'undoMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

ObjectTransaction comment: '
An ObjectTransaction knows how to remember the state of objects and revert them back to that state later on. It does this by making a *shallow* copy of the registered objects and everything connected to them, and then putting that into an identity dictionary keyed by the originals.

If you have to undo, you push the state from the shallow copies back into the originals.

Yes, that works, and it''s all you have to do. It even handles collections become:ing different sizes.

This is fairly independent of GLORP. You could use this mechanism in general, if you provided your own mechanism for figuring out what to register, or even just uncommented the one in here.

Instance Variables:
    undoMap	<IdentityDictionary>	 The dictionary of originals->copies.

'!


Smalltalk.Object subclass: #Mapping
    instanceVariableNames: 'descriptor attributeName attributeAccessor readOnly '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

Mapping subclass: #TypeMapping
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

Smalltalk.Object subclass: #DatabaseConverter
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #DatabaseTable
    instanceVariableNames: 'name fields primaryKeyFields foreignKeyConstraints parent schema '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #JoinPrinter
    instanceVariableNames: 'joinsToProcess availableTables query '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

DatabaseConverter subclass: #DelegatingDatabaseConverter
    instanceVariableNames: 'host stToDbSelector dbToStSelector '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

FunctionExpression subclass: #PostfixFunction
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

TypeMapping subclass: #FilteredTypeMapping
    instanceVariableNames: 'field key keyDictionary '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

FilteredTypeMapping comment: '
EnumeratedMapping knows what type an object should be based on the value of a single row.'!


Smalltalk.Object subclass: #Dialect
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Extensions'!

Dialect class instanceVariableNames: 'dialectName timestampClass '!

Smalltalk.Object subclass: #ElementBuilder
    instanceVariableNames: 'instance requiresPopulating key expression query fieldTranslations isExpired row '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

ElementBuilder comment: '
This is the abstract superclass of builders. These assemble information, either primitive data or objects, from a database result set.

Subclasses must implement the following messages:
    building objects
    	buildObjectFrom:
    	findInstanceForRow:useProxy:
    selecting fields
    	fieldsFromMyPerspective

Instance Variables:
    expression	<MappingExpression>	The expression we''re mapping. e.g. if the query is reading people, this might be the expression corresponding to "each address", meaning that we build the address object related to the main Person instance by the given relationship. 
    fieldTranslations	<Array of: Integer>	 The translation of the field positions from where they are in the descriptor to where they are in the row we''re reading. This is done so we can read the rows efficiently, by index, rather than doing lots of dictionary lookups by name. If we''re doing a simple read, the translations will probably be a no-op, but if we read multiple objects, some of the fields will be in different positions than they are in our table definition.
    instance	<Object>	The thing we''re constructing.
    isExpired	<Boolean>	If our instance is in cache, we use that instead. However, if the instance has expired, then we do something different (most likely force a refresh) than if it''s still alive.
    key	<Object>	The key for this row. This is lazily computed, and "self" is used a special marker to indicate that it hasn''t been computed yet.
    query	<AbstractReadQuery>	the query that we''re building results for.
    requiresPopulating	<Boolean>	Do we need to populate the object. Will be false if the object was found in cache and hasn''t expired.
    row	<Array>	The database results. May actually be a result set row of some sort rather than an array, depending on the dialect, but should always respond to indexing protocol.

'!


Smalltalk.Object subclass: #GlorpSession
    instanceVariableNames: 'system currentUnitOfWork cache accessor applicationData reusePreparedStatements '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

GlorpSession comment: '
This class has not yet been commented.  The comment should state the purpose of the class, what messages are subclassResponsibility, and the type and purpose of each instance and class variable.  The comment should also explain any unobvious aspects of the implementation.

Instance Variables:

    system	<ClassOfVariable>	description of variable''s function
    currentUnitOfWork	<ClassOfVariable>	description of variable''s function
    cache	<ClassOfVariable>	description of variable''s function
    accessor	<ClassOfVariable>	description of variable''s function
    application	<ClassOfVariable>	application-specific data'!


Smalltalk.Object subclass: #TableSorter
    instanceVariableNames: 'orderedTables tables visitedTables '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

Mapping subclass: #DictionaryMapping
    instanceVariableNames: 'keyMapping valueMapping '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

DictionaryMapping comment: '
This allows us to map a dictionary into tables. This breaks down into many cases.
String->Object
Object->Object
with representation either like a 1-many or like a many-many with information in the link table. The general idea is that we represent this as a compound mapping that can describe how the key maps and how the values maps. 

Instance Variables:

    keyMapping	<ClassOfVariable>	description of variable''s function
    valueMapping	<ClassOfVariable>	description of variable''s function'!


Smalltalk.Object subclass: #Tracing
    instanceVariableNames: 'base allTracings retrievalExpressions alsoFetchExpressions '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

Tracing comment: '
A tracing is a collection of expressions representing the graph of other objects which
are to be read at the same time as the root object.

Instance Variables:

    base	<Expression>	The base expression representing the root object. Same as the parameter to the query block
    allTracings	<Collection of: Expression>	The expressions representing each of the associated objects. e.g. base accounts, base amount serviceCharge .
    alsoFetchExpressions	<(Collection of: GlorpExpression)>	Objects to also retrieve, but not included in the result set, just knitted together with the other related objects.
    retrievalExpressions	<(Collection of: GlorpExpression)>	Objects to also retrieve, and to include in teh result set

'!


Smalltalk.Object subclass: #RowMap
    instanceVariableNames: 'rowDictionary '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

Smalltalk.Object subclass: #DatabaseType
    instanceVariableNames: 'name platform typeString '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

DatabaseType subclass: #TimeStampType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseType subclass: #InMemorySequenceDatabaseType
    instanceVariableNames: 'representationType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

InMemorySequenceDatabaseType class instanceVariableNames: 'Count '!

DatabaseType subclass: #AbstractNumericType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseType subclass: #AbstractStringType
    instanceVariableNames: 'width '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #DatabaseRow
    instanceVariableNames: 'table contents shouldBeWritten owner forDeletion '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseRow class instanceVariableNames: 'missingFieldIndicator '!

DatabaseRow comment: '
This represents the data to be written out to a row. Database rows are normally stored in a rowmap, keyed according to their table and the object that did the primary writes to them. We expect that that''s only one object, although embedded values are an exception to that.

Instance Variables:

    table	<DatabaseTable>	The table holding the data
    contents	<IdentityDictionary>	Holds the fields with their values, indirectly through FieldValueWrapper instances.
    shouldBeWritten	<Boolean>	Normally true, but can be set false to suppress writing of a particular row. Used with embedded value mappings, where we create their row, unify it with the parent row, and suppress writing of the original row.
    owner	<Object>	The primary object that wrote into this row, would also be the key into the rowmap.'!


DatabaseType subclass: #TimeType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

AbstractNumericType subclass: #NumericType
    instanceVariableNames: 'precision scale '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #Query
    instanceVariableNames: 'session criteria prepared expectedRows collectionType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

Smalltalk.Object subclass: #FieldUnifier
    instanceVariableNames: 'fields fieldsWithRows objects rows rowMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

FieldUnifier comment: '
This is a "Method Object" whose purpose is to set up a constraint in the row map between two field values. It''s called a Unifier because the constraints are reminiscent of Prolog-type unification, although much less general (and simpler to implement). There''s no ability to backtrack, and if we ever encounter a contradiction among constraints we throw an exception.  Essentially we just implement it by adding a layer of indirection. Rows can contain wrappers for values. If two or more values are constrained to be the same, we make sure they use the same (identical) wrapper. Then setting the value on one of the fields sets it on all of them.  The only reason this is tricky at all is the "or more" case, because we may need to merge if we discover constraints in the order e.g. a=b, c=d, a=c.

Instance Variables:
    fields	<SequenceableCollection>	
    fieldsWithRows	<SequenceableCollection>	I forget right now  :-)
    objects	<Object>	the persistent objects that are keys into the rowmap
    rowMap	<RowMap>	
    rows	<Collection>	

'!


Smalltalk.Object subclass: #Descriptor
    instanceVariableNames: 'describedClass tables multipleTableCriteria mappings system mappedFields cachePolicy typeResolver mapsPrimaryKeys '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

DatabaseType subclass: #DateType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

CachePolicy subclass: #TimedExpiryCachePolicy
    instanceVariableNames: 'timeout '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

TimedExpiryCachePolicy comment: '
This implements a cache that notes that an object is stale after some amount of time since it has been read.

Instance Variables:
    timeout	<Integer>	The time in seconds until we note an object as needing refreshing.

'!


Query subclass: #AbstractReadQuery
    instanceVariableNames: 'resultClass readsOneObject returnProxies shouldRefresh ordering tracing absentBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

AbstractReadQuery subclass: #ReadQuery
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

ReadQuery comment: '
This represents a general read query. By general we mean that it might require more than one trip to the database. It computes a "tracing" indicating which groups of objects can be read simultaneously, then constructs a group of corresponding SimpleQuery instances and executes them.'!


Smalltalk.Object subclass: #Join
    instanceVariableNames: 'sources targets base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

Join comment: '
This is a specialized variety of expression that is more constrained and is used for defining relationships. It has two main purposes
 - ease of construction: Relationships are normally defined by field to field equality expressions (my foreign key field = his primary key field). These are more tedious to create via block expressions, so this provides a simpler syntax.
 - constrained semantics. These define both read and write for the relationship, so fully general expressions won''t work (most notably, relations other than equality are hard to write). Using a primaryKeyExpression ensures that we satisfy these constraints.

I''m not completely sure this class is a good idea. It makes for an annoying assymetry between different kinds of expressions. This is especially notable now that we allow sources to be constants. It''s possible that all we need is an expression constructor that generates real expressions, but with more convenient syntax and ensuring that the constraints are met.

Note that although these are typically fk=pk, it''s allowed to be the other way around -- i.e. our object-level relationships can be the opposite of the way the fk''s "point" in the database.

Instance Variables:
    base	<BaseExpression>	The base on which we are built. Mostly used if we want to convert this into a real expression.
    sources	<SequenceableCollection of: (DatabaseField | ConstantExpression)> The source fields (typically the foreign keys)
    targets	<SequenceableCollection of: DatabaseField> The target fields (typically the targets of the foreign keys)

'!


FunctionExpression subclass: #InfixFunction
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Smalltalk.Collection subclass: #GlorpVirtualCollection
    instanceVariableNames: 'query session realObjects '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpQueries'!

GlorpVirtualCollection comment: '
This represents a virtual collection, i.e. one that we haven''t really read into memory yet. It responds to a reasonable subset of collection protocol, and will read the elements into memory only when necessary. So, e.g. a select: operation takes a query block, and is equivalent to AND:ing that query block to the main query.

To create a virtual collection, ask the session for one. e.g. session virtualCollectionOf: AClass.

This is an initial version which will read in the objects fairly eagerly. An optimization might be to defer certain types of operations depending on whether the block can be evaluated into SQL or not. e.g.
  collect: [:each | each name]
can be turned into a retrieve: operation. But 
  collect: [:each | each printString]
cannot. We could try to check the block for operations like collect: and detect:, deferring the point at which the objects will be read in.

Handling of ordering is also a little bit funny. The blocks we like for ordering aren''t compatible with sortedCollection type blocks. It''d be nice to be more compatible.

'!


Smalltalk.Object subclass: #TypeResolver
    instanceVariableNames: 'members system '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

TypeResolver subclass: #BasicTypeResolver
    instanceVariableNames: 'concreteMembers subclassDescriptorsBuilt rootDescriptor rootClass '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

TypeResolver subclass: #IdentityTypeResolver
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

GlorpExpression subclass: #ExpressionGroup
    instanceVariableNames: 'children '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

ExpressionGroup comment: '
This isn''t really an expression, in that it can never occur due to parsing. It''s a way of grouping several expressions together so that we can process them together, essentially making sure that the iteration methods will loop over all the expressions, but only do each node once, even if it occurs in multiple expressions.  This is used in processing order expressions to figure out what tables and join expressions we need.

Because it is only used in transient ways, it probably doesn''t implement all the required operations for normal expression usage.
'!


Smalltalk.Object subclass: #AttributeAccessor
    instanceVariableNames: 'attributeName lastClassUsed attributeIndex useDirectAccess '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

Mapping subclass: #ConditionalMapping
    instanceVariableNames: 'conditionalField conditionalMethod cases otherwiseCase conditionalFieldMapping '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

DatabaseType subclass: #BooleanType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

RowMap subclass: #RowMapForMementos
    instanceVariableNames: 'correspondenceMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

RowMapForMementos comment: '
This is a specialized version of RowMap for creating rowmaps out of the mementos in the undo/correspondence map. When doing partial writes we create a rowmap for the current state of the objects, then a rowmap for the original state, and difference the two.

The tricky part is that the mementos refer back to the original objects, so when we establish unification constraints between rows, they would establish them to original objects. This is wrong, and not trivial to debug.

So this rowmap keeps the correspondence map and knows that it has to compensate and get the memento for any related objects.
'!


Smalltalk.Object subclass: #DatabaseField
    instanceVariableNames: 'table name isPrimaryKey position type isNullable isUnique '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

AbstractStringType subclass: #CharType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

ProtoObject subclass: #MessageArchiver
    instanceVariableNames: 'myMessage myReceiver '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Smalltalk.Object subclass: #MultipleRowMapKey
    instanceVariableNames: 'keys '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpUnitOfWork'!

MultipleRowMapKey comment: '
This is a special (and rarely needed) form of row map key that allows an arbitrary number of objects to participate in it.'!


Smalltalk.Object subclass: #RowMapKey
    instanceVariableNames: 'key1 key2 '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

RowMapKey comment: '
This class serves as a key for a dictionary containing two sub-keys, where we want to be able to look up based on the identity of both sub-keys paired together. This is used primarily for many-to-many mappings indexing into rowmaps, where we want to key the row by the identity of the object that determines it, but there are two of them.

Instance Variables:

key1	<Object>	One sub-key.
key2	<Object>	The other sub-key.'''!


GlorpExpression subclass: #RelationExpression
    instanceVariableNames: 'relation leftChild rightChild outerJoin '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

RelationExpression subclass: #CollectionExpression
    instanceVariableNames: 'myLocalBase myLocalExpression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

CollectionExpression comment: '
This represents expressions on collection objects taking a block, which at the moment means just anySatisfy:

We treat this as a relation, but with the special properties that when we convert the right hand side into an expression we assume it''s a block and give it a base which is the left-hand side. Also, we don''t print this relation when printing SQL, we just print the right hand side.'!


BasicTypeResolver subclass: #FilteredTypeResolver
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

GlorpExpression subclass: #ObjectExpression
    instanceVariableNames: 'mappingExpressions requiresDistinct tableAliases fieldAliases '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

ObjectExpression subclass: #TableExpression
    instanceVariableNames: 'table base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

ObjectExpression subclass: #MappingExpression
    instanceVariableNames: 'name base outerJoin '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Smalltalk.Object subclass: #DescriptorSystem
    instanceVariableNames: 'session platform descriptors tables sequences typeResolvers cachePolicy allClasses useDirectAccessForMapping '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

DescriptorSystem subclass: #DynamicDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

DynamicDescriptorSystem comment: '
This is a descriptor system whose descriptors and tables are created dynamically rather than out of generated code. Note that identity is extremely important, so care is required to set these up properly.
'!


BasicTypeResolver subclass: #HorizontalTypeResolver
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

AbstractNumericType subclass: #AbstractIntegerType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

AbstractIntegerType subclass: #IntegerDatabaseType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

AbstractIntegerType subclass: #SerialType
    instanceVariableNames: 'generated sequence '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

AbstractIntegerType subclass: #SmallintDatabaseType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #DatabaseAccessor
    instanceVariableNames: 'connection currentLogin platform logging markLogEntriesWithTimestamp '
    classVariableNames: 'LoggingEnabled'
    poolDictionaries: ''
    category: 'Glorp-Database'!

ElementBuilder subclass: #DataElementBuilder
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

DataElementBuilder comment: '
This builds raw data items rather than persistent objects with descriptors. Used if we do something like 
  aQuery retrieve: [:each | each address streetName].
giving us back simple data objects.
This makes building them quite simple.'!


AbstractNumericType subclass: #DoubleType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseConverter subclass: #PluggableDatabaseConverter
    instanceVariableNames: 'stToDb dbToSt '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #DatabasePlatform
    instanceVariableNames: 'types converters useBinding reservedWords '
    classVariableNames: 'UseBindingIfSupported'
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabasePlatform class instanceVariableNames: 'converterRepository '!

AbstractReadQuery subclass: #SimpleQuery
    instanceVariableNames: 'fields distinctFields builders joins '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

SimpleQuery comment: '
This is a query that is directly executable. A single query might be more than we can do in a single database read, so we might have to break it down into simple queries. But at the moment we just break anything down into an equivalent single query.

Instance Variables:
    builders	<OrderedCollection of: ElementBuilder)>	The builders that will assemble the object from the row that this query returns.
    fields	<OrderedCollection of: DatabaseField>	The fields being selected.
    traceNodes	<Collection of: GlorpExpression>	 These describe the graph of the objects to be read, so we can specify customer, customer address and customer account all in one read.


'!


Smalltalk.Object subclass: #FieldValueWrapper
    instanceVariableNames: 'contents hasValue containedBy '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

ObjectExpression subclass: #BaseExpression
    instanceVariableNames: 'descriptor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

GlorpExpression subclass: #ParameterExpression
    instanceVariableNames: 'field base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Smalltalk.Object subclass: #CacheManager
    instanceVariableNames: 'subCaches session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

CacheManager comment: '
This is the entire cache for a session, consisting of multiple sub-caches, one per class.

Instance Variables:
    session	<Session>	The containing session.
    subCaches	<Dictionary from: Class to: Cache>	The per-class caches.

'!


CachePolicy subclass: #WeakVWCachePolicy
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

WeakVWCachePolicy comment: '
This is a cache policy that uses VisualWorks 7.x weak references (ephemerons) to store references to objects, letting them vanish if not referenced. It uses the numberOfElements inst var as an indicator of how many objects to keep hard references to, preventing objects from disappearing too quickly.

Instance Variables:
    
'!


TypeMapping subclass: #IdentityTypeMapping
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

TypeMapping subclass: #HorizontalTypeMapping
    instanceVariableNames: 'mappedClass isAbstract '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

Smalltalk.Object subclass: #UnitOfWork
    instanceVariableNames: 'session transaction deletedObjects newObjects rowMap commitPlan deletePlan commitInProgress '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-UnitOfWork'!

UnitOfWork comment: '
A UnitOfWork keeps track of objects which might potentially be modified and lets you roll them back or commit the changes into the database.

Instance Variables:
    newObjects	<IdentitySet of: Object>	The objects registered with this unit of work. newObjects is probably a bad name for this.
    session	<Session>	The session in which this is all taking place.
    transaction	<ObjectTransaction>	Keeps track of the original object state so that we can revert it.
    rowMap	<RowMap>	A holder for the rows when we are writing out changes.
    commitPlan	<(OrderedCollection of: DatabaseRow)>	The list of rows to be written, in order. Constructed by topological sorting the contents of the row map.

'!


Smalltalk.Object subclass: #ForeignKeyConstraint
    instanceVariableNames: 'sourceField targetField name suffixExpression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

AbstractStringType subclass: #VarCharType
    instanceVariableNames: 'typeName '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

ElementBuilder subclass: #ObjectBuilder
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

ObjectBuilder comment: '
This builds full-blown persistent objects with descriptors. This is the most common type of builder.'!


AbstractStringType subclass: #TextType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #FixedSizeQueue
    instanceVariableNames: 'maximumSize items '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

FixedSizeQueue comment: '
This is a fixed size queue of objects. It''s intended for keeping around a fixed number of references to objects in a weak dictionary. As such its API is rather limited (one method), and it''s write-only.

Instance Variables:
    items	<OrderedCollection>	The items in the queue
    maximumSize	<Integer>	How many items we''re allowed

'!


ProtoObject subclass: #Proxy
    instanceVariableNames: 'session query parameters value isInstantiated '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Queries'!

GlorpExpression subclass: #EmptyExpression
    instanceVariableNames: 'base value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Mapping subclass: #AdHocMapping
    instanceVariableNames: 'fromDbMappingBlock toDbMappingBlock mappedFields '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

AdHocMapping comment: '
AdHocMapping is a configurable sort of mapping, done via two blocks.

The protocol for this is still ugly because the users will have to explicitly make use of the field positions, and probably need to use the elementBuilder''s translation. This should be automated.

'!


Mapping subclass: #ConstantMapping
    instanceVariableNames: 'constantValue valueIsSession '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

ConstantMapping comment: '
Sometimes you just want a constant value to be set, either in the row, the object or both. And sometimes you just want a non-mapping (e.g. with a ConditionalMapping where one
of the conditions means "this isn''t mapped"). This mapping represents these situations.
It also handles the special case where it''s useful to have access to the session inside a
domain object, by allowing you to map it to an instance variable.

So far only the case of mapping to an inst var is implemented.

Instance Variables:
'!


Mapping subclass: #DirectMapping
    instanceVariableNames: 'field converter '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

Smalltalk.Object subclass: #DatabaseCommand
    instanceVariableNames: 'useBinding stream sqlString platform '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

DatabaseCommand subclass: #SelectCommand
    instanceVariableNames: 'query parameters boundExpressions blockFactor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

DatabaseCommand subclass: #RowBasedCommand
    instanceVariableNames: 'row '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

RowBasedCommand subclass: #DeleteCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

RowBasedCommand subclass: #UpdateCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

RowBasedCommand subclass: #InsertCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

Smalltalk.Object subclass: #DatabaseSequence
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseSequence subclass: #NamedSequence
    instanceVariableNames: 'name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseSequence subclass: #TableBasedSequence
    instanceVariableNames: 'sequenceTableName '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

NamedSequence subclass: #SQLServerSequence
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseSequence subclass: #JustSelectTheMaximumSequenceValueAndAddOne
    instanceVariableNames: 'tableName '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

JustSelectTheMaximumSequenceValueAndAddOne comment: '
This is a sequence that just does a select max(primaryKeyFieldName) for the table in question and adds one to it. This is, um, less-than-perfectly efficient, and I''m not at all clear that it''ll work for a multi-user system. But it''s what Store does on SQL Server, so we''d like to be able to mimic it.

Instance Variables:
    tableName	<DatabaseTable>	the table we sequence.'!


DatabaseSequence subclass: #NullSequence
    instanceVariableNames: ''
    classVariableNames: 'Singleton'
    poolDictionaries: ''
    category: 'Glorp-Database'!

DatabaseSequence subclass: #InMemorySequence
    instanceVariableNames: 'count '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #Cache
    instanceVariableNames: 'items policy mainCache extraReferences '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Core'!

Cache comment: '
This is the per-class cache of instances read from the database.

Instance Variables:
    items	<Dictionary from: Object to: Object>	The cached items, keyed by their primary key values
    policy	<CachePolicy>	The settings for this cache.

'!


AbstractNumericType subclass: #FloatType
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

Smalltalk.Object subclass: #GlorpPreparedStatement
    instanceVariableNames: 'signature statement '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Database'!

GlorpExpression subclass: #FieldExpression
    instanceVariableNames: 'field base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Expressions'!

Mapping subclass: #RelationshipMapping
    instanceVariableNames: 'referenceClass mappingCriteria shouldProxy query '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

RelationshipMapping subclass: #OneToOneMapping
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

OneToOneMapping subclass: #EmbeddedValueOneToOneMapping
    instanceVariableNames: 'fieldTranslation '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

EmbeddedValueOneToOneMapping comment: '
This represents a one-to-one mapping in which the referenced object is stored as part of the same table as the containing object.
'''!


RelationshipMapping subclass: #ToManyMapping
    instanceVariableNames: 'orderBy shouldWriteTheOrderField collectionType '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

ToManyMapping subclass: #OneToManyMapping
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!

ToManyMapping subclass: #ManyToManyMapping
    instanceVariableNames: 'relevantLinkTableFields rowMapKeyConstructorBlock '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Mappings'!


!CachePolicy methodsFor: 'accessing'!

dictionaryClass
    ^Dictionary.!

expiryAction
    ^expiryAction!

expiryAction: aSymbol
    "See class comment for possible values"
    expiryAction := aSymbol!

numberOfElements
    ^numberOfElements!

numberOfElements: anInteger
    numberOfElements := anInteger! !

!CachePolicy methodsFor: 'initialize'!

collectionForExtraReferences
    ^nil.!

initialize
    numberOfElements := 100.
    expiryAction := #remove.!

newItemsIn: aCache
    ^self dictionaryClass new: 20.! !

!CachePolicy methodsFor: 'expiry'!

notifyOfExpiry: anObject in: aCache 
    anObject glorpNoticeOfExpiryIn: aCache session.!

release: aCache
    (expiryAction == #notify or: [expiryAction == #notifyAndRemove])
    	ifTrue: [
    		aCache do: [:each |
    			each glorpNoticeOfExpiryIn: aCache session]].!

takeExpiryActionForKey: key withValue: anObject in: aCache
    expiryAction == #refresh
    	ifTrue: [aCache session refresh: anObject].
    (#(#notify #notifyAndRemove) includes: expiryAction) ifTrue: [
    	self notifyOfExpiry: anObject in: aCache].
    (#(#remove #notifyAndRemove) includes: expiryAction) ifTrue: [
    	aCache removeKey: key ifAbsent: []].! !

!CachePolicy methodsFor: 'wrap/unwrap'!

cacheEntryFor: anObject
    ^anObject.!

contentsOf: aCacheEntry
    ^aCacheEntry.!

hasExpired: aCacheEntry
    ^false.!

markEntryAsCurrent: aCacheEntry in: aCache
    ^self.! !

!CachePolicy class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!CachePolicy class methodsFor: 'instance creation'!

default
    ^Dialect isVisualWorks ifTrue: [WeakVWCachePolicy new] ifFalse: [self new].!

new
    ^super new initialize.! !

!Login methodsFor: 'accessing'!

= aLogin 
    ^self class == aLogin class and: 
    		[self name = aLogin name and: 
    				[self database class = aLogin database class and: 
    						[self username = aLogin username and: 
    								[self password = aLogin password 
    									and: [self connectString = aLogin connectString]]]]]!

connectString
    ^connectString!

connectString: aString 
    connectString := aString!

database
    ^database!

database: aSymbol 
    database := aSymbol!

hash
    ^self name hash + self database class hash + self username hash 
    	+ self password hash + self connectString hash!

name
    name isNil ifTrue: [^self connectString] ifFalse: [^name].!

name: aString
    name := aString.!

password
    ^password!

password: aString 
    password := aString!

username
    ^username!

username: aString 
    username := aString! !

!Login methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: 'a Login('.
    database printOn: aStream.
    aStream nextPutAll: ', '.
    username printOn: aStream.
    aStream nextPutAll: ', '.
    password printOn: aStream.
    aStream nextPutAll: ', '.
    connectString printOn: aStream.
    aStream nextPutAll: ')'.! !

!Login class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpression methodsFor: 'printing'!

className
    ^self class name.!

displayString
    | stream |
    stream := String new writeStream.
    self printOnlySelfOn: stream.
    ^stream contents.!

printOn: aStream 
    self printTreeOn: aStream!

printOnlySelfOn: aStream
    self subclassResponsibility.!

printTreeOn: aStream
    self subclassResponsibility.! !

!GlorpExpression methodsFor: 'preparing'!

additionalExpressions
    ^#().!

additionalExpressionsIn: aQuery 
    "Return the collection of additional expressions (representing joins) that this expression tree requires"

    | allExpressions |
    allExpressions := ExpressionGroup with: self.
    allExpressions addAll: aQuery ordering.
    allExpressions addAll: aQuery tracing additionalExpressions.
    ^allExpressions
    	inject: OrderedCollection new 
    	into: [:sum :each | 
    		sum addAll: each additionalExpressions.
    		sum].!

allRelationsFor: rootExpression do: aBlock andBetweenDo: anotherBlock
    "In any normal relationship, there's only one thing. Just do it"
    aBlock value: rootExpression leftChild value: rootExpression rightChild.!

allTables
    ^self inject: Set new into: [:sum :each | 
    	sum addAll: each tables. sum].!

allTablesToPrint
    ^self inject: Set new into: [:sum :each | 
    	sum addAll: each tablesToPrint. sum].!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    self subclassResponsibility.!

assignTableAliasesStartingAt: anInteger
    ^anInteger.!

hasBindableExpressionsIn: aCommand
    ^false.!

prepareIn: aQuery 
    (self additionalExpressionsIn: aQuery) do: [:each |	
    	aQuery addJoin: each].!

tableForANSIJoin
    "Which table will we join to."
    ^nil.!

tables
    ^#().!

tablesToPrint
    ^#().!

validate! !

!GlorpExpression methodsFor: 'iterating'!

anySatisfy: aBlock
    "Answer true if aBlock answers true for any element of the receiver.
     An empty collection answers false."

    self do: [:each| (aBlock value: each) ifTrue: [^true]].
    ^false!

collect: aBlock
    | newCollection |
    newCollection := OrderedCollection new.
    self do: [:each | newCollection add: (aBlock value: each)].
    ^newCollection.!

detect: aBlock 
    "Evaluate aBlock with each of the receiver's elements as the argument.
    Answer the first element for which aBlock evaluates to true."

    ^self detect: aBlock ifNone: [self notFoundError]!

detect: aBlock ifNone: exceptionBlock 
    "Evaluate aBlock with each of the receiver's elements as the argument.
    Answer the first element for which aBlock evaluates to true."

    self do: [:each | (aBlock value: each) ifTrue: [^each]].
    ^exceptionBlock value!

do: aBlock
    "Iterate over the expression tree"

    self do: aBlock skipping: IdentitySet new.!

do: aBlock skipping: aSet
    "Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    aBlock value: self.!

inject: anObject into: aBlock
    | sum |
    sum := anObject.
    self do: [:each | sum := aBlock value: sum value: each].
    ^sum!

select: aBlock
    | newCollection |
    newCollection := OrderedCollection new.
    self do: [:each | (aBlock value: each) ifTrue: [newCollection add: each]].
    ^newCollection! !

!GlorpExpression methodsFor: 'api'!

AND: anExpression
    "This method doesn't really have to exist, because it would be inferred using operationFor:, but it's included here for efficiency and to make it a little less confusing how relation expression get created. Note that the two expression must already be  built on the same base!"

    anExpression isNil ifTrue: [^self].
    ^RelationExpression named: #AND basedOn: self withArguments: (Array with: anExpression).!

asGlorpExpression
    ^self.!

base
    self subclassResponsibility.!

equals: anExpression
    ^RelationExpression named: #= basedOn: self withArguments: (Array with: anExpression).!

get: aSymbol withArguments: anArray
    self subclassResponsibility.!

getFunction: aSymbol withArguments: anArray
    | expression |
    expression := FunctionExpression for: aSymbol withArguments: anArray.
    expression isNil ifTrue: [^nil].
    expression base: self.
    ^expression.!

OR: anExpression
    "This method doesn't really have to exist, because it would be inferred using operationFor:, but it's included here for efficiency and to make it a little less confusing how relation expression get created.  Note that the two expression must already be  built on the same base!"
    anExpression isNil ifTrue: [^self].
    ^RelationExpression named: #OR basedOn: self withArguments: (Array with: anExpression).!

parameter: aConstantExpression
    "Create a parameter expression with the given name. But note that the name doesn't have to be a string. Database fields, symbols, and integers are all plausible"
    ^ParameterExpression forField: aConstantExpression value basedOn: self.! !

!GlorpExpression methodsFor: 'inspecting'!

inspectorHierarchies
    | hierarchy |
    hierarchy := ((Smalltalk at: #Tools ifAbsent: [^#()])
    	at: #Trippy ifAbsent: [^#()])
    	at: #Hierarchy ifAbsent: [^#()].
    ^Array with: (hierarchy
    		id: #expression
    		label: 'Expression Tree'
    		parentBlock: [:each | nil]
    		childrenBlock: [:each | each inspectorChildren])! !

!GlorpExpression methodsFor: 'testing'!

canBeUsedForRetrieve
    "Return true if this is a valid argument for a retrieve: clause"
    ^false.!

canBind
    "Return true if this represents a value that can be bound into a prepared statement"
    ^false.!

canKnit
    "Return true if, when building objects, we can knit the object corresponding to this expression to a related object. Roughly speaking, is this a mapping expression"
    ^false.!

hasImpliedClauses
    "Return true if this implies additional SQL clauses beyond just a single field expression"
    ^false.!

hasTableAliases
    ^false.!

isEmptyExpression
    ^false.!

isGlorpExpression
    ^true.!

isPrimaryKeyExpression
    ^false.! !

!GlorpExpression methodsFor: 'accessing'!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^self subclassResponsibility.!

hasDescriptor
    ^false.!

printsTable
    ^false.!

requiresDistinct
    ^false.!

valueIn: aDictionary
    "Return the value associated with this expression given the parameters in aDictionary. Only meaningful for ParameterExpressions"

    ^self.! !

!GlorpExpression methodsFor: 'converting'!

asGeneralGlorpExpression
    "Convert the result to a general (tree-format) expression, if it's the more limited primary key expression"
    ^self.!

asGlorpExpressionForDescriptor: aDescriptor
    self ultimateBaseExpression descriptor: aDescriptor.!

asGlorpExpressionOn: aBaseExpression
    aBaseExpression ultimateBaseExpression == self ultimateBaseExpression ifTrue: [^self].
    ^self rebuildOn: aBaseExpression.!

asIndependentJoins
    "If this is an ANDed clause, split it into independent joins"
    ^Array with: self.! !

!GlorpExpression methodsFor: 'initialize'!

in: anExpression
    ^RelationExpression named: #IN basedOn: self withArguments: (Array with: anExpression).!

initialize! !

!GlorpExpression methodsFor: 'primary keys'!

primaryKeyFromDictionary: aDictionary
    "Given a set of parameters, return a primary key suitable for retrieving our target. We can't do this for general expressions, so indicate failure by returning nil"
    ^nil.! !

!GlorpExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpression class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!FunctionExpression methodsFor: 'accessing'!

arguments: anArray
    ^self.!

base
    ^base.!

base: anExpression
    base := anExpression.!

canHaveBase
    ^true.!

field
    ^base field.!

function: aString
    function := aString.!

function: aString arguments: anArray
    self function: aString.!

mappedFields
    ^base mappedFields.!

table
    ^self field table.! !

!FunctionExpression methodsFor: 'navigating'!

ultimateBaseExpression
    ^base ultimateBaseExpression.! !

!FunctionExpression methodsFor: 'printing'!

printOnlySelfOn: aStream
    aStream nextPutAll: function.!

printSQLOn: aStream withParameters: aDictionary
    
    self subclassResponsibility.!

printTreeOn: aStream 
    aStream 
    	nextPutAll: function! !

!FunctionExpression methodsFor: 'api'!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    | newBase |
    newBase := base asExpressionJoiningSource: source toTarget: target.
    ^self new function: function; base: newBase.!

get: aSymbol withArguments: anArray
    self error: 'Expressions cannot be built on function expressions'.! !

!FunctionExpression methodsFor: 'testing'!

canBeUsedForRetrieve
    "Return true if this is a valid argument for a retrieve: clause"
    ^true.! !

!FunctionExpression methodsFor: 'As yet unclassified'!

valueInBuilder: anElementBuilder
    ^self base valueInBuilder: anElementBuilder.! !

!FunctionExpression class methodsFor: 'private'!

initialize
    self resetPossibleFunctions.!

initializePossibleFunctions
    "self initializePossibleFunctions"
    possibleFunctions := IdentityDictionary new
    	at: #descending put: (PostfixFunction named: 'DESC');
    	at: #distinct put: (InfixFunction named: 'DISTINCT');
    	at: #max put: (InfixFunction named: 'MAX');
    	at: #not put: (InfixFunction named: 'NOT');
    	yourself.!

named: aString
    "Used for creating template instances only"

    ^self new function: aString.!

resetPossibleFunctions
    "self resetPossibleFunctions"
    possibleFunctions := nil.! !

!FunctionExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FunctionExpression class methodsFor: 'instance creation'!

for: aSymbol withArguments: anArray
    | function newFunction |
    function := self possibleFunctions at: aSymbol ifAbsent: [^nil].
    newFunction := function copy.
    newFunction arguments: anArray.
    ^newFunction.! !

!FunctionExpression class methodsFor: 'functions'!

possibleFunctions
    possibleFunctions isNil ifTrue: [self initializePossibleFunctions].
    ^possibleFunctions.! !

!ConstantExpression methodsFor: 'printing'!

printOnlySelfOn: aStream
    aStream print: value!

printSQLOn: aStream withParameters: aDictionary
    self value glorpPrintSQLOn: aStream.!

printTreeOn: aStream 
    aStream print: value! !

!ConstantExpression methodsFor: 'testing'!

canBind
    "Return true if this represents a value that can be bound into a prepared statement"
    ^true.! !

!ConstantExpression methodsFor: 'accessing'!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^false.!

value
    ^value!

value: anObject
    value := anObject!

valueIn: aDictionary
    ^value! !

!ConstantExpression methodsFor: 'preparing'!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    ^self.!

rebuildOn: aBaseExpression
    ^self.! !

!ConstantExpression methodsFor: 'converting'!

asGlorpExpressionOn: aBaseExpression
    ^self.! !

!ConstantExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ConstantExpression class methodsFor: 'instance creation'!

for: anObject
    ^self new value: anObject.! !

!ObjectTransaction methodsFor: 'initializing'!

initialize
    self initializeUndoMap.!

initializeUndoMap
    undoMap := IdentityDictionary new.! !

!ObjectTransaction methodsFor: 'private/restoring'!

isShapeOf: original differentThanThatOf: copy
    ^original class ~~ copy class or: [original basicSize ~= copy basicSize]!

restoreIndexedInstanceVariablesOf: original toThoseOf: copy
    1 to: copy basicSize do: [:index |
    	original basicAt: index put: (copy basicAt: index)]!

restoreNamedInstanceVariablesOf: original toThoseOf: copy
    1 to: copy class instSize do: [:index |
    	original instVarAt: index put: (copy instVarAt: index)]!

restoreShapeOf: original toThatOf: copy
    | newOriginal |
    (copy class isBits or: [copy class isVariable])
    	ifTrue: [newOriginal := copy class basicNew: copy basicSize]
    	ifFalse: [newOriginal := copy class basicNew].
    original become: newOriginal.!

restoreStateOf: original toThatOf: copy 
    (self isShapeOf: original differentThanThatOf: copy) 
    	ifTrue: [self restoreShapeOf: original toThatOf: copy].
    self restoreNamedInstanceVariablesOf: original toThoseOf: copy.
    self restoreIndexedInstanceVariablesOf: original toThoseOf: copy! !

!ObjectTransaction methodsFor: 'begin/commit/abort'!

abort
    undoMap keysAndValuesDo: [:original :copy | self restoreStateOf: original toThatOf: copy]!

begin
    self initializeUndoMap!

commit
    self initializeUndoMap! !

!ObjectTransaction methodsFor: 'accessing'!

undoMap
    ^undoMap! !

!ObjectTransaction methodsFor: 'private/registering'!

instanceVariablesOf: anObject do: aBlock
    (1 to: anObject class instSize) do: [:index | aBlock value: (anObject instVarAt: index)].
    (1 to: anObject basicSize) do: [:index | aBlock value: (anObject basicAt: index)]!

shallowCopyOf: anObject ifNotNeeded: aBlock
    | copy |
    copy := anObject shallowCopy.
    ^copy == anObject 
    	ifTrue: [aBlock value]
    	ifFalse: [copy]! !

!ObjectTransaction methodsFor: 'registering'!

isRegistered: anObject 
    "Note: We can never have a situation where a proxy is registered but its contents aren't, so we don't have to worry about that ambiguous case."
    | realObject |
    realObject := self realObjectFor: anObject ifNone: [^false].
    ^undoMap includesKey: realObject.!

realObjectFor: anObject 
    "If this is a proxy, return the contents (if available). Otherwise, return nil"
    ^self realObjectFor: anObject ifNone: [nil].!

realObjectFor: anObject ifNone: aBlock
    "If this is a proxy, return the contents (if available). Otherwise, evaluate the block"
    ^anObject class == Proxy 
    	ifTrue: [anObject isInstantiated ifTrue: [anObject getValue] ifFalse: [aBlock value]]
    	ifFalse: [anObject]!

register: anObject 
    "Make anObject be a member of the current transaction. Return the object if registered, or nil otherwise"

    | copy realObject |
    (self requiresRegistrationFor: anObject) ifFalse: [^nil].
    realObject := self realObjectFor: anObject ifNone: [^nil].
    copy := self shallowCopyOf: realObject ifNotNeeded: [^nil].
    undoMap at: realObject put: copy.
    self registerTransientInternalsOfCollection: realObject.
    ^realObject!

registeredObjectsDo: aBlock
    "Iterate over all our objects. Note that this will include objects without descriptors. Be sure we're iterating over a copy of the keys, because this will add objects to the undoMap"
    undoMap keys do: aBlock.!

registerTransientInternalsOfCollection: aCollection
    "If this is a collection, then we may need to register any internal structures it has, e.g. an internal array. This is implementation dependent for the collection. We will also explicitly exclude strings"

    aCollection glorpIsCollection ifFalse: [^self].
    aCollection class isBits ifTrue: [^self].
    aCollection glorpRegisterCollectionInternalsIn: self.!

requiresRegistrationFor: anObject
    | realObject |
    realObject := self realObjectFor: anObject ifNone: [^false].
    ^(self isRegistered: realObject) not.! !

!ObjectTransaction class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!ObjectTransaction class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpHelper class methodsFor: 'helpers'!

do: aBlock for: aCollection separatedBy: separatorBlock
    | array |
    array := aCollection asArray.
    1 to: array size do: [:i |
    	| each |
    	each := array at: i.
    	aBlock value: each.
    	i = array size ifFalse: [
    		separatorBlock value]].!

print: printBlock on: stream for: aCollection separatedBy: separatorString
    | array |
    array := aCollection asArray.
    1 to: array size do: [:index |
    	stream nextPutAll: (printBlock value: (array at: index)).
    	index == array size ifFalse: [
    		stream nextPutAll: separatorString]].!

separate: aCollection by: aOneArgumentBlock
    ^aCollection inject: Dictionary new into: [:dict :each |
    	| val |
    	val := aOneArgumentBlock value: each.
    	(dict at: val ifAbsentPut: [OrderedCollection new]) add: each].! !

!GlorpHelper class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Mapping methodsFor: 'accessing'!

allTables
    self subclassResponsibility.!

attributeAccessor
    ^attributeAccessor!

attributeName
    "Private - Answer the value of the receiver's ''attributeName'' instance variable."

    ^attributeName!

attributeName: anObject
    "Private - Set the value of the receiver's ''attributeName'' instance variable to the argument, anObject."

    attributeName := anObject.
    self initializeAccessor.!

descriptor
    "Private - Answer the value of the receiver's ''descriptor'' instance variable."

    ^descriptor!

descriptor: anObject
    "Private - Set the value of the receiver's ''descriptor'' instance variable to the argument, anObject."

    descriptor := anObject!

fieldsForSelectStatement
    "Return a collection of fields that this mapping will read from a row"

    ^self mappedFields!

initializeAccessor
    attributeName == nil ifTrue: [^self].
    attributeAccessor := AttributeAccessor newForAttributeNamed: attributeName.
    self updateUseDirectAccess!

readOnly
    ^readOnly.!

readOnly: aBoolean
    readOnly := aBoolean.!

session
    
    ^self descriptor session.!

system
    
    ^self descriptor system.!

updateUseDirectAccess
    (self attributeAccessor notNil 
    and: [self descriptor notNil
    and: [self descriptor system notNil]])
    		ifTrue: [self attributeAccessor useDirectAccess: self descriptor system useDirectAccessForMapping]! !

!Mapping methodsFor: 'testing'!

canBeUsedForRetrieve
    "Return true if this is a valid argument for a retrieve: clause"
    self isRelationship ifFalse: [^true].
    ^self isToManyRelationship not.!

controlsTables
    "Return true if this type of mapping 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

    self subclassResponsibility!

hasImpliedClauses
    "Return true if this implies multiple sql clauses"
    ^false.!

includesSubFieldsInSelectStatement
    ^false!

isRelationship
    "True when the mapping associates different persistent classes."

    ^self subclassResponsibility!

isStoredInSameTable
    "True when the mapping is between two objects that occupy the same table, e.g. an embedded mapping."

    ^self subclassResponsibility!

isToManyRelationship
    ^false.!

isTypeMapping
    ^false!

mappedFields
    self subclassResponsibility! !

!Mapping methodsFor: 'mapping'!

applicableMappingForObject: anObject 
    "For polymorphism with conditional mappings"
    ^self!

expressionFor: anObject
    "Return our expression using the object's values. e.g. if this was a direct mapping from id->ID and the object had id: 3, then return TABLE.ID=3"

    self subclassResponsibility.!

mapFromObject: anObject intoRowsIn: aRowMap
    self subclassResponsibility.!

mapObject: anObject inElementBuilder: anObject1
    self subclassResponsibility.!

readBackNewRowInformationFor: anObject fromRowsIn: aRowMap 
    "
    self subclassResponsibility. ?"!

referencedIndependentObjectsFrom: anObject
    self subclassResponsibility.!

trace: aTracing context: anExpression
    self subclassResponsibility.!

translateFields: anOrderedCollection 
    "Normal mappings don't translate"
    ^anOrderedCollection.! !

!Mapping methodsFor: 'public'!

getValueFrom: anObject
    ^attributeAccessor getValueFrom: anObject.!

printOn: aStream
    super printOn: aStream.
    aStream 
    	nextPutAll: '(';
    	nextPutAll: (attributeName isNil ifTrue: [''] ifFalse: [attributeName]) ;
    	nextPutAll: ')'.!

setValueIn: anObject to: aValue
    attributeAccessor setValueIn: anObject to: aValue.! !

!Mapping methodsFor: 'printing SQL'!

allRelationsFor: rootExpression do: aBlock andBetweenDo: anotherBlock
    "Normal mappings just operate on a single expression"
    aBlock value: rootExpression leftChild value: rootExpression rightChild.! !

!Mapping methodsFor: 'initialize/release'!

initialize
    readOnly := false.! !

!Mapping methodsFor: 'preparing'!

joinExpressionFor: anExpression
    ^nil.!

multipleTableExpressionsFor: anExpression
    ^#().! !

!Mapping class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!Mapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TypeMapping methodsFor: 'testing'!

canBeTypeMappingParent
    ^true!

isAbstract
    self subclassResponsibility!

isRelationship
    ^false.!

isTypeMapping
    ^true!

isTypeMappingRoot
    | superClassDescriptor |
    superClassDescriptor := self descriptorForSuperclass.
    ^superClassDescriptor isNil or: [ superClassDescriptor typeMapping canBeTypeMappingParent not ]! !

!TypeMapping methodsFor: 'accessing'!

mappedClass
    ^self descriptor describedClass! !

!TypeMapping methodsFor: 'mapping'!

addTypeMappingCriteriaTo: collection in: expression
    ^self!

allDescribedConcreteClasses
    ^Array with: (self describedClass)!

describedClass
    ^self descriptor describedClass!

describedConcreteClassFor: aRow withBuilder: builder
    ^self mappedClass!

descriptorForSuperclass
    ^self system descriptorFor: self mappedClass superclass!

mapFromObject: anObject intoRowsIn: aRowMap
    "do  nothing"!

mapObject: anObject inElementBuilder: anElementBuilder
    "do  nothing"!

referencedIndependentObjectsFrom: anObject
    ^#().!

typeMappingRoot
    ^self isTypeMappingRoot 
    	ifTrue: [self mappedClass]
    	ifFalse: [self descriptorForSuperclass typeMapping typeMappingRoot]! !

!TypeMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseConverter methodsFor: 'accessing'!

name
    ^name.!

name: aString
    name := aString.! !

!DatabaseConverter methodsFor: 'converting'!

convert: anObject fromDatabaseRepresentationAs: aDatabaseType 
    self subclassResponsibility!

convert: anObject toDatabaseRepresentationAs: aDatabaseType 
    self subclassResponsibility! !

!DatabaseConverter methodsFor: 'initialize'!

initialize
    name := #unnamed.! !

!DatabaseConverter methodsFor: 'printing'!

printOn: aString
    aString nextPutAll: 'DatabaseConverter(', name, ')'.! !

!DatabaseConverter class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseConverter class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!DatabaseTable methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream 
    	nextPutAll: '(';
    	nextPutAll: (name isNil ifTrue: [''] ifFalse: [name]);
    	nextPutAll: ')'.!

printSQLOn: aWriteStream withParameters: aDictionary
    aWriteStream nextPutAll: self name!

sqlString
    ^name.! !

!DatabaseTable methodsFor: 'create/delete in db'!

creationStringFor: aDatabaseAccessor 
    | creationStream |
    creationStream := WriteStream on: (String new: 1000).
    creationStream
    	nextPutAll: 'CREATE TABLE ';
    	nextPutAll: self name;
    	nextPutAll: ' ( ';
    	nl.
    self printFieldsOn: creationStream for: aDatabaseAccessor.
    aDatabaseAccessor platform supportsConstraints ifTrue: [
    	self hasPrimaryKeyConstraints 
    		ifTrue: [self printDelimiterOn: creationStream].
    	self printPrimaryKeyConstraintsOn: creationStream for: aDatabaseAccessor.
    	"self hasForeignKeyConstraints ifTrue: [self printDelimiterOn: creationStream].
    	self printForeignKeyConstraintsOn: creationStream for: aDatabaseAccessor"].
    creationStream nextPutAll: ')'.
    ^creationStream contents!

dropForeignKeyConstraintsFromAccessor: aDatabaseAccessor 
    self foreignKeyConstraints 
    	do: [:each | aDatabaseAccessor dropConstraint: each]!

dropFromAccessor: aDatabaseAccessor
    aDatabaseAccessor platform supportsConstraints
    	ifTrue: [self dropPrimaryKeyConstraintsFromAccessor: aDatabaseAccessor].
    aDatabaseAccessor dropTableNamed: self name.!

dropPrimaryKeyConstraintsFromAccessor: aDatabaseAccessor
    self primaryKeyFields isEmpty
    	ifFalse:
    		[aDatabaseAccessor
    			doCommand:
    				[aDatabaseAccessor
    					executeSQLString:
    						'ALTER TABLE ' , self name , ' DROP CONSTRAINT '
    							, self primaryKeyUniqueConstraintName]
    			ifError: [:ex | Transcript show: (ex messageText ifNil: [ex printString])].
    		aDatabaseAccessor
    			doCommand:
    				[aDatabaseAccessor
    					executeSQLString:
    						'ALTER TABLE ' , self name , ' DROP CONSTRAINT '
    							, self primaryKeyConstraintName]
    			ifError: [:ex | Transcript show: (ex messageText ifNil: [ex printString])]].!

primaryKeyConstraintName
    ^self name, '_PK'.!

primaryKeyUniqueConstraintName
    ^self name, '_UNIQ'.!

printDelimiterOn: aStream
    
    aStream
    	nextPut: $,;
    	nl!

printFieldsOn: creationStream for: aDatabaseAccessor 
    GlorpHelper 
    	do: [:each | each printCreationStringFor: aDatabaseAccessor on: creationStream]
    	for: fields
    	separatedBy: [self printDelimiterOn: creationStream]!

printForeignKeyConstraintsOn: creationStream for: anObject 
    GlorpHelper 
    	print: [:each | each creationString]
    	on: creationStream
    	for: foreignKeyConstraints
    	separatedBy: ','!

printPrimaryKeyConstraintsOn: aStream for: aDatabaseAccessor 
    self primaryKeyFields isEmpty ifTrue: [^self].
    aStream nextPutAll: 'CONSTRAINT '.
    aStream nextPutAll: self primaryKeyConstraintName.
    aStream nextPutAll: ' PRIMARY KEY  ('.
    GlorpHelper 
    	print: [:each | each name]
    	on: aStream
    	for: self primaryKeyFields
    	separatedBy: ','.
    aStream nextPut: $).

    aStream
    	nextPutAll: ',';
    	nl.

    aStream nextPutAll: 'CONSTRAINT '.
    aStream nextPutAll: self primaryKeyUniqueConstraintName.
    aStream nextPutAll: ' UNIQUE  ('.
    GlorpHelper 
    	print: [:each | each name]
    	on: aStream
    	for: self primaryKeyFields
    	separatedBy: ','.
    aStream nextPut: $)! !

!DatabaseTable methodsFor: 'testing'!

hasCompositePrimaryKey
    ^primaryKeyFields size > 1.!

hasConstraints
    ^self hasForeignKeyConstraints or: [self hasPrimaryKeyConstraints]!

hasFieldNamed: aString
    ^fields contains: [:each | each name = aString]!

hasForeignKeyConstraints
    ^foreignKeyConstraints isEmpty not!

hasPrimaryKeyConstraints
    ^self primaryKeyFields isEmpty not.! !

!DatabaseTable methodsFor: 'private/fields'!

addAsPrimaryKeyField: aField
    primaryKeyFields := primaryKeyFields, (Array with: aField)! !

!DatabaseTable methodsFor: 'comparing'!

<= aTable
    ^self name <= aTable name.! !

!DatabaseTable methodsFor: 'accessing'!

creator
    ^self schema!

creator: aString
    "For backward-compatibility. Use schema: instead."
    self schema: aString.!

fields
    ^fields!

foreignKeyConstraints
    "Private - Answer the value of the receiver's ''foreignKeyConstraints'' instance variable."

    ^foreignKeyConstraints!

isAliased
    ^parent notNil.!

name
    "Private - Answer the value of the receiver's ''name'' instance variable."

    ^(schema isNil or: [schema isEmpty]) ifTrue: [name] ifFalse: [schema, '.', name].!

name: anObject
    name := anObject!

parent
    ^parent.!

parent: aDatabaseTable
    parent := aDatabaseTable.!

primaryKeyFields
    ^primaryKeyFields.!

qualifiedName
    ^self name.!

schema
    ^schema!

schema: aString
    schema := aString!

sqlTableName
    "Our name, as appropriate for the list of tables in a SQL statement. Take into account aliasing"
    ^parent isNil 
    	ifTrue: [self name]
    	ifFalse: [parent sqlTableName, ' ', self name].! !

!DatabaseTable methodsFor: 'initialize'!

initialize
    schema := ''.
    fields := OrderedCollection new.
    primaryKeyFields := #().
    foreignKeyConstraints := OrderedCollection new: 4.!

postInitializeIn: aDescriptorSystem
    "Any initialization that happens after all the fields have been added"

    fields do: [:each | each postInitializeIn: aDescriptorSystem].! !

!DatabaseTable methodsFor: 'fields'!

addField: aField
    fields add: aField.
    aField isPrimaryKey ifTrue: [
    	self addAsPrimaryKeyField: aField].
    aField table: self.
    aField position: fields size.
    ^aField.!

addForeignKeyFrom: sourceField to: targetField
    ^self
    	addForeignKeyFrom: sourceField
    	to: targetField
    	suffixExpression: nil.!

addForeignKeyFrom: sourceField to: targetField suffixExpression: suffixExpression
    | newFK |
    newFK := ForeignKeyConstraint
    				sourceField: sourceField
    				targetField: targetField
    				suffixExpression: suffixExpression.
    newFK name: newFK name , (foreignKeyConstraints size + 1) printString.
    ^foreignKeyConstraints add: newFK.!

createFieldNamed: aString type: dbType
    | existingField |
    existingField := fields detect: [:each | each name = aString] ifNone: [nil].
    (existingField notNil)
    ifTrue: [self error: 'field ', aString, ' already exists'].
    ^self addField: (DatabaseField named: aString type: dbType)!

fieldNamed: aString
    ^fields detect: [:each | each name = aString]!

newFieldNamed: aString
    ^self error: 'use #createFieldNamed:type:'! !

!DatabaseTable class methodsFor: 'instance creation'!

named: aString
    ^self new name: aString.!

new
    ^super new initialize.! !

!DatabaseTable class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!JoinPrinter methodsFor: 'initializing'!

setUp
    availableTables := Set new.! !

!JoinPrinter methodsFor: 'printing'!

nextJoin
    ^joinsToProcess detect: [:eachJoinExpression |
    	eachJoinExpression tablesForANSIJoin anySatisfy: [:eachTable |
    		availableTables includes: eachTable]].!

printJoinsOn: aCommand
    joinsToProcess := query joins copy.
    availableTables := Set with: self rootTable.
    joinsToProcess size timesRepeat: [aCommand nextPut: $(].
    aCommand nextPutAll: self rootTable sqlTableName.
    [joinsToProcess isEmpty] whileFalse: [
    	| next |
    	next := self nextJoin.
    	next printForANSIJoinTo: availableTables on: aCommand.
    	aCommand nextPut: $).
    	joinsToProcess remove: next.
    	availableTables addAll: (next tablesForANSIJoin)].
    self printLeftoverTablesOn: aCommand.!

printLeftoverTablesOn: aCommand
    "Now there might be leftover tables whose joins were implied directly by the where clause"
    | leftOverTables |
    leftOverTables := self allTables asSet copy.
    availableTables do: [:each | leftOverTables remove: each ifAbsent: []].
    leftOverTables isEmpty ifFalse: [aCommand nextPutAll: ', '].
    GlorpHelper
    	print: [:each | each sqlTableName]
    	on: aCommand
    	for: leftOverTables
    	separatedBy: ', '.! !

!JoinPrinter methodsFor: 'accessing'!

allTables
    ^query tablesToPrint.!

query: aQuery
    query := aQuery.	
    self setUp.!

rootTable
    "Pick a table to start with"
    ^self allTables first.! !

!JoinPrinter class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!JoinPrinter class methodsFor: 'instance creation'!

for: aQuery
    ^self new query: aQuery.! !

!DelegatingDatabaseConverter methodsFor: 'converting'!

convert: anObject fromDatabaseRepresentationAs: aDatabaseType 
    ^host perform: dbToStSelector with: anObject with: aDatabaseType!

convert: anObject toDatabaseRepresentationAs: aDatabaseType 
    ^host perform: stToDbSelector with: anObject with: aDatabaseType.! !

!DelegatingDatabaseConverter methodsFor: 'initialize-release'!

hostedBy: anObject fromStToDb: stDbSelector fromDbToSt: dbStSelector
    host := anObject.
    stToDbSelector := stDbSelector.
    dbToStSelector := dbStSelector! !

!DelegatingDatabaseConverter class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DelegatingDatabaseConverter class methodsFor: 'instance creation'!

hostedBy: anObject fromStToDb: stDbSelector fromDbToSt: dbStSelector
    ^super new
    	hostedBy: anObject fromStToDb: stDbSelector fromDbToSt: dbStSelector! !

!PostfixFunction methodsFor: 'printing'!

printSQLOn: aStream withParameters: aDictionary
    
    base printSQLOn: aStream withParameters: aDictionary.
    aStream nextPutAll: ' '; nextPutAll: function.! !

!PostfixFunction class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FilteredTypeMapping methodsFor: 'types'!

describedConcreteClassFor: aRow withBuilder: builder
    ^self keyDictionary at: (aRow atIndex: (builder translateFieldPosition: field))!

keys
    ^self keyDictionary keys! !

!FilteredTypeMapping methodsFor: 'initialize-release'!

buildKeyDictionary
    | subclassDescriptor |
    keyDictionary := Dictionary new.
    keyDictionary at: key put: descriptor describedClass.
    descriptor describedClass allSubclasses do: [:each |
    	subclassDescriptor := descriptor system descriptorFor: each.
    	keyDictionary at: subclassDescriptor typeMapping keyedBy put: subclassDescriptor describedClass ]!

field: aField keyedBy: aKey
    field := aField.
    key := aKey.! !

!FilteredTypeMapping methodsFor: 'accessing'!

field
    ^field!

keyDictionary
    keyDictionary isNil ifTrue: [ self buildKeyDictionary ].
    ^keyDictionary!

keyedBy
    ^key!

keyedBy: aKey
    key := aKey!

mappedFields
    "Return a collection of fields that this mapping will write into any of the containing object's rows"

    ^Array with: self field.! !

!FilteredTypeMapping methodsFor: 'mapping'!

addTypeMappingCriteriaTo: collection in: base
    | singleRightValue r l |
    singleRightValue := self keys size = 1.
    r := ConstantExpression for: (singleRightValue
    										ifTrue: [self keys asArray first]
    										ifFalse: [self keys]).
    l := FieldExpression forField: self field basedOn: base.
    collection add: (singleRightValue ifTrue: [l equals: r] ifFalse: [l in: r]).!

mapFromObject: anObject intoRowsIn: aRowMap
    | row |
    readOnly ifTrue: [^self].
    row := aRowMap findOrAddRowForTable: self field table withKey: anObject.
    row at: field put: key.!

referencedIndependentObjectsFrom: anObject
    ^#().!

trace: aTracing context: anExpression
    ^self.! !

!FilteredTypeMapping class methodsFor: 'instance creation'!

to: field keyedBy: key
    ^self new
    	field: field
    	keyedBy: key! !

!FilteredTypeMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Dialect class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Dialect class methodsFor: 'dates'!

addSeconds: seconds to: aTime
    self isVisualWorks ifTrue: [^aTime addSeconds: seconds].
    self isDolphin ifTrue: [^self addTimeForDolphin: aTime seconds: seconds].
    self isGNU ifTrue: [^aTime addSeconds: seconds].
    self error: 'not implemented'.!

addTimeForDolphin: aTime seconds: seconds
    "Dolphin's time/date arithmetic is pretty weak, especially for timestamps. Hack around it. This is likely only to work for seconds <24 hours"
    | result |
    ^aTime class == Time
    	ifTrue: [Time fromMilliseconds: (aTime asMilliseconds + (seconds * 1000)) \\  86400000]
    	ifFalse:
    		[result := self timestampClass
    			date: aTime date
    			time: (self addTimeForDolphin: aTime time seconds: seconds).
    		(seconds > 0 and: [result time < aTime time]) ifTrue: [
    			result date: (result date addDays: 1)].
    		(seconds < 0 and: [result time > aTime time]) ifTrue: [
    			result date: (result date addDays: -1)].
    		^result].!

newDateWithYears: year months: monthNumber days: dayOfMonth
    "Read the y/m/d given. m is a 1-indexed month number (i.e. Jan=1)"

    self isVisualWorks ifTrue: [^Date newDay: dayOfMonth monthNumber: monthNumber year: year].
    self isGNU ifTrue: [^Date newDay: dayOfMonth monthIndex: monthNumber year: year].
    self error: 'not implemented'.
"	self isDolphin ifTrue: [ | dateToModify newDate|
    	dateToModify := aDate class == Date ifTrue: [aDate] ifFalse: [aDate date].
    	newDate := Date newDay: dayOfMonth monthNumber: monthNumber year: year.
    	dateToModify setDays: newDate asDays.
    	^self]."!

newTimestampWithYears: year months: monthNumber days: dayOfMonth hours: hours minutes: minutes seconds: seconds milliseconds: milliseconds offset: utcOffsetSeconds
    
    | date time ts |
    self isGNU
        ifTrue:
                [^self timestampClass
		    year: year month: monthNumber day: dayOfMonth
                    hour: hours minute: minutes second: seconds
                    offset: (Duration fromSeconds: utcOffsetSeconds) ].

    date := self newDateWithYears: year months: monthNumber days: dayOfMonth.
    time := self newTimeWithHours: hours minutes: minutes seconds: seconds milliseconds: milliseconds.
    self isVisualWorks
    	ifTrue:
    		[ts := self timestampClass fromDate: date andTime: time.
    		^ts addMilliseconds: milliseconds].
    self error: 'not implemented'.!

newTimeWithHours: hours minutes: minutes seconds: seconds milliseconds: milliseconds
    self isGNU ifTrue: [^Time fromSeconds: (hours * 60 * 60) + (minutes * 60) + seconds].
    self isVisualWorks ifTrue: [^Time fromSeconds: (hours * 60 * 60) + (minutes * 60) + seconds].
    self error: 'Not implemented yet'.!

supportsMillisecondsInTimes
    self isGNU ifTrue: [^false].
    self isVisualWorks ifTrue: [^false].
    self isDolphin ifTrue: [^true].
    self error: 'not yet implemented'.!

timeOffsetFromGMT
    self isGNU ifTrue: [Time timezoneBias / (60 * 60) ].
    self isVisualWorks ifTrue: [^((self smalltalkAt: #TimeZone) default secondsFromGMT / (60 * 60))].
    ^0.!

timestampClass
    timestampClass == nil ifFalse: [^timestampClass].
    Dialect isGNU ifTrue: [^timestampClass := (self smalltalkAt: #DateTime)].
    (Dialect isSqueak or: [Dialect isDolphin])
    	ifTrue: [^timestampClass := self smalltalkAt: #TimeStamp].
    Dialect isVisualWorks ifTrue: [^timestampClass := self smalltalkAt: #Timestamp].
    self error: 'Not yet implemented'.!

timestampNow
    self isGNU ifTrue: [^self timestampClass dateAndTimeNow].
    Dialect isSqueak ifTrue: [^self timestampClass current].
    Dialect isVisualWorks ifTrue: [^self timestampClass now].
    Dialect isDolphin ifTrue: [^self timestampClass current].
    self error: 'Not yet implemented'.!

timestampNowUTC
    self isGNU ifTrue: [^self timestampClass utcDateAndTimeNow].
    Dialect isVisualWorks ifTrue: [^(self smalltalkAt: #Timestamp) fromSeconds: Time secondClock].
    Dialect isDolphin ifTrue: [self error: 'not supported'].
    self error: 'Not yet implemented'.!

totalSeconds
    self isGNU ifTrue: [^Time utcSecondClock].
    self isVisualAge ifTrue: [^(self smalltalkAt: #AbtTimestamp) now totalSeconds].
    ^Time totalSeconds.! !

!Dialect class methodsFor: 'private'!

basicIsDolphin
    ^Smalltalk includesKey: #DolphinSplash.!

basicIsGNU
    ^Smalltalk includesKey: #BindingDictionary!

basicIsSqueak
    ^(Smalltalk respondsTo: #vmVersion) 
    	and: [(Smalltalk vmVersion copyFrom: 1 to: 6) = 'Squeak']!

basicIsVisualAge
    ^Smalltalk class name == #EsSmalltalkNamespace.
"	| sys |
    sys := Smalltalk at: #System ifAbsent: [^false].
    (sys respondsTo: #vmType) ifFalse: [^false].
    ^sys vmType = 'ES'"!

basicIsVisualWorks
    ^Smalltalk class name == #NameSpace.
"Smalltalk class selectors do: [ :s | 
    	(s == #versionName and: [ (Smalltalk versionName copyFrom: 1 to: 11) = 'VisualWorks']) 
    	    ifTrue: [^true]].
    ^false"!

determineDialect
    self basicIsDolphin ifTrue: [^dialectName := #Dolphin].
    self basicIsGNU ifTrue: [^dialectName := #GNU].
    self basicIsVisualAge ifTrue: [^dialectName := #VisualAge].
    self basicIsVisualWorks ifTrue: [^dialectName := #VisualWorks].
    self basicIsSqueak ifTrue: [^dialectName := #Squeak].
    self error: 'I don''t know what dialect this is'.! !

!Dialect class methodsFor: 'identifying'!

dialectName
    dialectName isNil ifTrue: [self determineDialect].
    ^dialectName.!

isDolphin
    ^self dialectName = #Dolphin.!

isGNU
    ^self dialectName = #GNU.!

isSqueak
    ^self dialectName = #Squeak.!

isVisualAge
    ^self dialectName = #VisualAge.!

isVisualWorks
    ^self dialectName = #VisualWorks.! !

!Dialect class methodsFor: 'general portability'!

garbageCollect
    Dialect isGNU ifTrue: [^ObjectMemory globalGarbageCollect].
    Dialect isVisualWorks ifTrue: [^ObjectMemory quickGC].
    Dialect isVisualAge ifTrue: [^(self smalltalkAt: #System) collectGarbage].
    self error: 'not implemented yet'.!

instVarNameFor: attributeName
    Dialect isGNU ifTrue: [ ^attributeName asSymbol ].
    ^attributeName asString!

smalltalkAssociationAt: aName
    self isVisualWorks ifTrue: [^aName asQualifiedReference].
    ^Smalltalk associationAt: aName asSymbol.!

smalltalkAt: aName
    ^self smalltalkAt: aName ifAbsent: [self error: 'element not found'].!

smalltalkAt: aName ifAbsent: aBlock
    self isVisualWorks ifTrue: [^aName asQualifiedReference value].
    ^Smalltalk at: aName asSymbol ifAbsent: aBlock.!

tokensBasedOn: tokenString in:aString
    self isGNU ifTrue: [^aString subStrings: tokenString first].
    self isVisualWorks ifTrue: [^aString tokensBasedOn: tokenString first].
    self isSqueak ifTrue: [^aString findTokens: tokenString].
    self isDolphin ifTrue:[^aString subStrings: tokenString].
    self error: 'not implemented yet'.! !

!Dialect class methodsFor: 'numbers'!

coerceToDoublePrecisionFloat: aNumber
    self isGNU ifTrue: [^aNumber asFloatD].
    self isVisualWorks ifTrue: [^aNumber asDouble].
    ^aNumber!

doublePrecisionFloatClass
    self isGNU ifTrue: [^self smalltalkAt: #FloatD].
    self isVisualWorks ifTrue: [^self smalltalkAt: #Double].
    ^Float.!

readFixedPointFrom: aString
    self isVisualWorks ifTrue: [^(self smalltalkAt: #FixedPoint) readFrom: (ReadStream on: aString)].
    self isDolphin ifTrue: [^Number readFrom: (ReadStream on: aString, 's')].
    self isGNU ifTrue: [^(Number readFrom: (ReadStream on: aString))
        asScaledDecimal: (aString size - (aString indexOf: $. ifAbsent: [ aString size ])) ].

    self error: 'not implemented'.! !

!Dialect class methodsFor: 'binding'!

unbindableClassNames
    self isVisualWorks ifTrue: [^#(#FixedPoint #LargePositiveInteger #LargeNegativeInteger)].
    ^#().! !

!ElementBuilder methodsFor: 'accessing'!

canCauseDuplicateRows
    ^false.!

expression
    ^expression!

expression: anExpression
    expression := anExpression.!

fieldTranslations
    ^fieldTranslations!

fieldTranslations: aDictionary 
    fieldTranslations := aDictionary.!

instance
    ^instance!

query
    ^query!

query: aQuery 
    query := aQuery!

requiresDistinct
    ^expression requiresDistinct.!

row
    ^row!

row: anArray
    "Since nil is a possible key value, use self as a special marker to indicate we haven't found the key yet"
    row == anArray ifFalse: [
    	key := self].
    row := anArray.!

session
    ^expression descriptor session.!

system
    ^self session system.! !

!ElementBuilder methodsFor: 'executing'!

hasFieldTranslations
    ^self fieldTranslations notNil! !

!ElementBuilder methodsFor: 'building objects'!

buildObjectFrom: anArray 
    self subclassResponsibility.!

findInstanceForRow: aRow useProxy: useProxies
    self subclassResponsibility.!

knitResultIn: aSimpleQuery
    "Connect up our built object with any other builders that use the same thing"

    ^self.!

registerObjectInUnitOfWork
    "If there is a current unit of work, then we must register in it, after population because that way the state is already in place. The nil checks are mostly for safety during unit tests, as those conditions should never occur in real use"
    query isNil ifTrue: [^self].
    query session isNil ifTrue: [^self].
    query session register: instance.! !

!ElementBuilder methodsFor: 'selecting fields'!

fieldsFromMyPerspective
    self subclassResponsibility.! !

!ElementBuilder methodsFor: 'translating fields'!

translateFieldPosition: aDatabaseField 
    fieldTranslations isNil ifTrue: [^aDatabaseField position].
    ^fieldTranslations at: aDatabaseField.!

valueOf: anExpression
    ^expression valueInBuilder: self.!

valueOfField: aField
    "aField is either a database field, or a constant expression containing a non-varying value that isn't derived from the row"
    (aField class == ConstantExpression) ifTrue: [^aField value].
    ^self row atIndex: (self translateFieldPosition: aField).!

valueOfField: aField in: aRow
    "Since the elementBuilder now holds the row, #valueOfField: is preferred protocol, but some things (e.g. ad hoc mapping blocks) might still be using this, so left for compatibility"
    (aField class == ConstantExpression) ifTrue: [^aField value].
    ^aRow atIndex: (self translateFieldPosition: aField).! !

!ElementBuilder methodsFor: 'initializing'!

initialize! !

!ElementBuilder class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ElementBuilder class methodsFor: 'private'!

classFor: anExpression 
    ^anExpression hasDescriptor
    	ifTrue: [ObjectBuilder]
    	ifFalse: [DataElementBuilder].! !

!ElementBuilder class methodsFor: 'instance creation'!

for: anExpression
    ^(self classFor: anExpression) new
    	expression: anExpression.!

for: anExpression in: aQuery
    ^(self classFor: anExpression) new
    	expression: anExpression;
    	query: aQuery.!

new
    ^super new initialize.! !

!GlorpSession methodsFor: 'private'!

expiredInstanceOf: aClass key: key
    ^cache expiredInstanceOf: aClass key: key.!

markAsCurrentOfClass: aClass key: key
    cache markAsCurrentOfClass: aClass key: key.!

privateGetCache
    ^cache.!

privateGetCurrentUnitOfWork
    ^currentUnitOfWork.!

realObjectFor: anObject 
    "If this is a proxy, return the contents (if available). Otherwise, return nil"
    ^self realObjectFor: anObject ifNone: [nil].!

realObjectFor: anObject ifNone: aBlock
    "If this is a proxy, return the contents (if available). Otherwise, evalute the block"
    ^anObject class == Proxy 
    	ifTrue: [anObject isInstantiated ifTrue: [anObject getValue] ifFalse: [aBlock value]]
    	ifFalse: [anObject]! !

!GlorpSession methodsFor: 'events'!

sendPostFetchEventTo: anObject
    anObject glorpPostFetch: self.!

sendPostWriteEventTo: anObject
    anObject glorpPostWrite: self.!

sendPreWriteEventTo: anObject
    anObject glorpPreWrite: self.! !

!GlorpSession methodsFor: 'api/queries'!

delete: anObject
    | realObject |
    "Get the real object, instantiating if necessary"
    realObject := anObject yourself.
    self hasUnitOfWork
    	ifTrue: [currentUnitOfWork delete: realObject]
    	ifFalse: [self beginUnitOfWork. currentUnitOfWork delete: realObject. self commitUnitOfWork.].!

execute: aQuery
    | preliminaryResult |
    preliminaryResult := aQuery executeIn: self.
    ^aQuery readsOneObject
    	ifTrue: [self filterDeletionFrom: preliminaryResult]
    	ifFalse: [self filterDeletionsFrom: preliminaryResult].!

hasExpired: anObject 
    ^cache hasExpired: anObject.!

readManyOf: aClass
    ^self execute: (Query returningManyOf: aClass).!

readManyOf: aClass where: aBlock
    ^self execute: (Query returningManyOf: aClass where: aBlock).!

readOneOf: aClass where: aBlock
    ^self execute: (Query returningOneOf: aClass where: aBlock).!

refresh: anObject
    | exp query realObject descriptor |
    realObject := self realObjectFor: anObject ifNone: [^self].
    descriptor := self descriptorFor: realObject.
    descriptor isNil ifTrue: [self error: 'Cannot refresh an object with no descriptor'].
    exp := descriptor primaryKeyExpressionFor: realObject.
    query := Query returningOneOf: realObject class where: exp.
    query shouldRefresh: true.
    ^self execute: query.! !

!GlorpSession methodsFor: 'accessing'!

accessor
    ^accessor!

accessor: aDatabaseAccessor 
    accessor := aDatabaseAccessor.
    system isNil ifFalse: [system platform: (accessor platform)].!

applicationData
    ^applicationData!

applicationData: anObject	
    applicationData := anObject!

platform
    ^self system platform.!

reusePreparedStatements: aBoolean
    reusePreparedStatements := aBoolean.!

system
    ^system! !

!GlorpSession methodsFor: 'copying'!

copy
    ^self shallowCopy postCopy.!

postCopy
    super postCopy.
    self initializeCache.
    currentUnitOfWork := nil.
    accessor := accessor copy.! !

!GlorpSession methodsFor: 'api'!

descriptorFor: aClassOrInstance
    ^system descriptorFor: aClassOrInstance.!

hasDescriptorFor: aClass
    ^system hasDescriptorFor: aClass.!

register: anObject 
    | realObject |
    currentUnitOfWork isNil ifTrue: [^self].
    realObject := self realObjectFor: anObject ifNone: [^self].

    (self isNew: realObject) 
    	ifTrue: [currentUnitOfWork registerAsNew: realObject]
    	ifFalse: [currentUnitOfWork register: realObject]!

registerAsNew: anObject 
    currentUnitOfWork isNil ifTrue: [^self].
    currentUnitOfWork registerAsNew: anObject.!

system: aSystem 
    aSystem session: self.
    accessor isNil ifFalse: [aSystem platform: (accessor currentLogin database)].
    system := aSystem.! !

!GlorpSession methodsFor: 'read/write'!

filterDeletionFrom: anObject
    self hasUnitOfWork ifFalse: [^anObject].
    (currentUnitOfWork willDelete: anObject)
    	ifTrue: [^nil].
    ^anObject.!

filterDeletionsFrom: aCollection
    "This will need to change if we have cursored collections"
    self hasUnitOfWork ifFalse: [^aCollection].
    currentUnitOfWork hasPendingDeletions ifFalse: [^aCollection].
    ^aCollection reject: [:each |
    	currentUnitOfWork willDelete: each].!

writeRow: aDatabaseRow
    | command |
    aDatabaseRow shouldBeWritten ifFalse: [^self].
    aDatabaseRow preWriteAssignSequencesUsing: self.
    command := self commandForRow: aDatabaseRow.
    self reusePreparedStatements
    	ifTrue: [accessor executeCommandReusingPreparedStatements: command]
    	ifFalse: [accessor executeCommand: command].
    aDatabaseRow postWriteAssignSequencesUsing: self.! !

!GlorpSession methodsFor: 'internal/writing'!

commandForRow: aDatabaseRow 
    
    (aDatabaseRow forDeletion) ifTrue: [^DeleteCommand forRow: aDatabaseRow useBinding: self useBinding platform: self platform].
    ^(self shouldInsert: aDatabaseRow)
    	ifTrue: [^InsertCommand forRow: aDatabaseRow useBinding: self useBinding platform: self platform]
    	ifFalse: [^UpdateCommand forRow: aDatabaseRow useBinding: self useBinding platform: self platform].!

createDeleteRowsFor: anObject in: rowMap
    "Create records for rows that require deletion"

    (self descriptorFor: anObject) createDeleteRowsFor: anObject in: rowMap.!

createRowsFor: anObject in: rowMap
    | descriptor |
    descriptor := self descriptorFor: anObject class.
    descriptor isNil ifFalse: [descriptor createRowsFor: anObject in: rowMap].!

shouldInsert: aDatabaseRow 
    ^(self cacheContainsObjectForRow: aDatabaseRow) not.!

tablesInCommitOrder
    ^(TableSorter for: system allTables) sort.! !

!GlorpSession methodsFor: 'caching'!

cacheAt: aKey  forClass: aClass ifNone: failureBlock
    ^cache lookupClass: aClass key: aKey ifAbsent: failureBlock.!

cacheAt: keyObject put: valueObject 
    ^cache at: keyObject insert: valueObject!

cacheContainsObjectForClass: aClass key: aKey 
    "Just test containment, don't return the result or trigger anything due to expiration"
    ^cache
    	containsObjectForClass: aClass
    	key: aKey.!

cacheContainsObjectForRow: aDatabaseRow
    ^self 
    	cacheContainsObjectForClass: aDatabaseRow owner class
    	key: aDatabaseRow primaryKey!

cacheLookupForClass: aClass key: aKey 
    ^self 
    	cacheAt: aKey
    	forClass: aClass
    	ifNone: [nil]!

cacheLookupObjectForRow: aDatabaseRow
    ^self 
    	cacheLookupForClass: aDatabaseRow owner class
    	key: aDatabaseRow primaryKey!

cacheRemoveObject: anObject
    | key |
    key := (self descriptorFor: anObject) primaryKeyFor: anObject.
    cache removeClass: anObject class key: key ifAbsent: [].!

hasExpired: aClass key: key
    ^cache hasExpired: aClass key: key.!

hasObjectExpiredOfClass: aClass withKey: key
    ^cache hasObjectExpiredOfClass: aClass withKey: key.!

isRegistered: anObject
    currentUnitOfWork isNil ifTrue: [^false].
    ^currentUnitOfWork isRegistered: anObject.!

lookupRootClassFor: aClass
    | descriptor |
    descriptor := self system descriptorFor: aClass.
    ^descriptor notNil
    		ifTrue: [ descriptor typeMappingRootDescriptor describedClass ]
    		ifFalse: [ aClass ]! !

!GlorpSession methodsFor: 'testing'!

isNew: anObject 
    "When registering, do we need to add this object to the collection of new objects? New objects are treated specially when computing what needs to be written, since we don't have their previous state"
    "This will break for composite keys (Really? Why? Do we need to test that if the key is a collection with a nil value, rather than just nil?)"

    | key descriptor |
    (currentUnitOfWork isRegistered: anObject) ifTrue: [^false].
    descriptor := self descriptorFor: anObject.
    descriptor isNil ifTrue: [^false].
    "For embedded values we assume that they are not new. This appears to work. I can't really justify it."
    self needsWork: 'cross your fingers'.
    descriptor mapsPrimaryKeys ifFalse: [^false].

    key := descriptor primaryKeyFor: anObject.
    key isNil ifTrue: [^true].
    ^(self cacheContainsObjectForClass: anObject class key: key) not.!

isUninstantiatedProxy: anObject
    ^anObject class == Proxy and: [anObject isInstantiated not].!

reusePreparedStatements
    ^reusePreparedStatements and: [self useBinding].!

useBinding
    ^self platform useBinding.! !

!GlorpSession methodsFor: 'api/transactions'!

beginTransaction
    accessor beginTransaction.!

beginUnitOfWork
    self hasUnitOfWork ifTrue: [self error: 'Cannot nest units of work yet'].
    currentUnitOfWork := UnitOfWork new.
    currentUnitOfWork session: self.!

commitTransaction
    accessor commitTransaction!

commitUnitOfWork
    self isInTransaction
    	ifTrue: [currentUnitOfWork commit]
    	ifFalse: [self inTransactionDo: [currentUnitOfWork commit]].
    currentUnitOfWork := nil.!

hasUnitOfWork
    ^currentUnitOfWork notNil.!

inTransactionDo: aBlock
    | alreadyInTransaction |
    [ 
    alreadyInTransaction := self isInTransaction.
    alreadyInTransaction ifFalse: [self beginTransaction].
    aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
    alreadyInTransaction ifFalse: [self commitTransaction]]
    	ifCurtailed:
    		[alreadyInTransaction ifFalse: [self rollbackTransaction]].!

inUnitOfWorkDo: aBlock
    [
    self beginUnitOfWork.
    aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
    self commitUnitOfWork]
    	ifCurtailed:
    		[self rollbackUnitOfWork].!

isInTransaction
    ^accessor isInTransaction.!

rollbackTransaction
    accessor doCommand: [ accessor rollbackTransaction] ifError: [:ex | ].!

rollbackUnitOfWork
    currentUnitOfWork abort.
    currentUnitOfWork := nil.!

transact: aBlock
    "Evaluate aBlock inside a unit of work. Start a database transaction at the beginning and commit it at the end. If we don' terminate normally, roll everything back.  This might more consistently be  called inUnitOfWorkWithTransactionDo:, but that's too verbose"
    | alreadyInTransaction |
    [[
    alreadyInTransaction := self isInTransaction.
    alreadyInTransaction ifFalse: [self beginTransaction].
    self beginUnitOfWork.
    aBlock numArgs = 1 ifTrue: [aBlock value: self] ifFalse: [aBlock value].
    self commitUnitOfWork.
    alreadyInTransaction ifFalse: [self commitTransaction]]
    	ifCurtailed:
    		[self rollbackUnitOfWork]]
    		ifCurtailed: [alreadyInTransaction ifFalse: [self rollbackTransaction]].! !

!GlorpSession methodsFor: 'initialize'!

initialize
    
    reusePreparedStatements := true.
    self initializeCache.!

initializeCache
    cache := CacheManager forSession: self.!

reset
    self initializeCache.
    accessor reset.
    currentUnitOfWork := nil.! !

!GlorpSession methodsFor: 'virtual collections'!

virtualCollectionOf: aClass
    ^GlorpVirtualCollection on: aClass in: self.! !

!GlorpSession class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpSession class methodsFor: 'instance creation'!

forSystem: aSystem 
    ^self new system: aSystem!

new
    ^super new initialize.! !

!TableSorter methodsFor: 'accessing'!

addTable: aTable 
    tables add: aTable!

hasBeenVisited: aTable
    ^visitedTables includes: aTable.!

markVisited: aTable
    visitedTables add: aTable.! !

!TableSorter methodsFor: 'sorting'!

sort
    orderedTables := OrderedCollection new: tables size.
    tables do: [:each | self visit: each].
    ^orderedTables!

visit: aTable 
    "The essential bit of topological sort. Visit each node in post-order, traversing dependencies, based on foreign key constraints to database-generated fields. "

    (self hasBeenVisited: aTable) ifTrue: [^self].
    self markVisited: aTable.
    self visitDependentTablesFor: aTable.
    orderedTables add: aTable!

visitDependentTablesFor: aTable 
    aTable foreignKeyConstraints do: [:eachConstraint | 
    	| fieldFromOtherTable |
    	fieldFromOtherTable := eachConstraint targetField.
      self visit: fieldFromOtherTable table.]! !

!TableSorter methodsFor: 'initializing'!

initialize
    tables := OrderedCollection new: 100.
    visitedTables := IdentitySet new: 100.! !

!TableSorter class methodsFor: 'instance creation'!

for: tables
    | sorter |
    sorter := self new.
    tables do: [:each |
    	sorter addTable: each].
    ^sorter.!

new
    ^super new initialize.! !

!TableSorter class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DictionaryMapping methodsFor: 'accessing'!

keyMapping: aMapping 
    keyMapping := aMapping.!

valueMapping: aMapping 
    valueMapping := aMapping.! !

!DictionaryMapping class methodsFor: 'instance creation'!

attributeName: aSymbol keyMapping: keyMapping valueMapping: valueMapping
    ^self new
    	attributeName: aSymbol;
    	keyMapping: keyMapping;
    	valueMapping: valueMapping.! !

!DictionaryMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Tracing methodsFor: 'accessing'!

addExpression: anExpression
    self addExpression: anExpression andDo: [:ignore |].!

addExpression: anExpression andDo: aBlock
    | exp |
    exp := anExpression asGlorpExpressionOn: base.
    (allTracings includes: exp) ifFalse: [
    	allTracings add: exp.
    	aBlock value: exp].!

additionalExpressions
    | all |
    alsoFetchExpressions isEmpty ifTrue: [^retrievalExpressions].
    all := OrderedCollection new.
    all addAll: self retrievalExpressions.
    all addAll: self alsoFetchExpressions.
    ^all.!

allTracings
    ^allTracings.!

alsoFetchExpressions
    ^alsoFetchExpressions!

base
    ^base!

base: anExpression 
    base := anExpression!

retrievalExpressions
    ^retrievalExpressions.! !

!Tracing methodsFor: 'setup'!

setup
    "We have been put into a query. If we aren't to trace anything else, trace the base"
    retrievalExpressions isEmpty ifTrue: [
    	allTracings add: base.
    	retrievalExpressions add: base].!

updateBase: aBaseExpression
    "Make sure we have the same base as the query"
    | transformed |
    transformed := IdentityDictionary new.
    base == aBaseExpression ifTrue: [^self].
    base := aBaseExpression.
    allTracings := allTracings collect: [:each | | new | new := each asGlorpExpressionOn: base.
    	transformed at: each put: new.
    	new].
    retrievalExpressions := retrievalExpressions collect: [:each | 
    	transformed at: each].
    alsoFetchExpressions := alsoFetchExpressions collect: [:each | 
    	transformed at: each].! !

!Tracing methodsFor: 'api'!

alsoFetch: anExpression 
    "Add the expression as something which will be explicitly retrieved and knit together with other results, but NOT included in the result list"

    self addExpression: anExpression andDo: [:exp |
    	alsoFetchExpressions add: exp].!

retrieve: anExpression 
    "Add the expression as something which will be explicitly retrieved and knit together with other results, but NOT included in the result list"
    self addExpression: anExpression andDo: [:exp |
    	retrievalExpressions add: exp].! !

!Tracing methodsFor: 'initialize'!

initialize
    base := BaseExpression new.
    allTracings := OrderedCollection new: 2.
    retrievalExpressions := Set new: 3.
    alsoFetchExpressions := Set new: 3.! !

!Tracing methodsFor: 'querying'!

tracesThrough: aMapping
    ^aMapping isStoredInSameTable.! !

!Tracing class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Tracing class methodsFor: 'instance creation'!

for: aQuery
    ^self new base: aQuery criteria ultimateBaseExpression.!

new
    ^super new initialize.! !

!RowMap methodsFor: 'private/mapping'!

adjustForMementos: objects
    ^self.!

collectionMementoFor: aCollection
    ^aCollection.!

dictionaryClassRequiredForKeysOfType: aClass
    ^(aClass == RowMapKey or: [aClass == MultipleRowMapKey])
    	ifTrue: [Dictionary]
    	ifFalse: [IdentityDictionary].!

reverseLookup: anObject
    ^anObject.!

rowsForKey: aKey 
    "Return a collection of all rows for any table which are keyed by aKey"

    | rowsForKey |
    rowsForKey := OrderedCollection new: 5.
    rowDictionary do: 
    		[:each | 
    		| row |
    		row := each at: aKey ifAbsent: [nil].
    		row isNil ifFalse: [rowsForKey add: row]].
    ^rowsForKey.!

subMapForTable: aTable
    
    ^self subMapForTable: aTable withKey: nil.!

subMapForTable: aTable ifAbsent: aBlock 
    ^rowDictionary at: aTable ifAbsent: aBlock!

subMapForTable: aTable withKey: anObject 
    ^rowDictionary at: aTable
    	ifAbsentPut: [(self dictionaryClassRequiredForKeysOfType: anObject class) new]!

tables
    ^rowDictionary keys.! !

!RowMap methodsFor: 'lookup'!

addRow: aRow forTable: aTable withKey: aKey 
    | submap |
    submap := self subMapForTable: aTable withKey: aKey.
    ^submap at: aKey put: aRow!

findOrAddRowForTable: aTable withKey: aKey 
    | submap |
    submap := self subMapForTable: aTable withKey: aKey.
    ^submap at: aKey ifAbsentPut: [DatabaseRow newForTable: aTable withOwner: aKey]!

includesRowForTable: aTable withKey: aKey
    (self subMapForTable: aTable ifAbsent: [^false]) at: aKey ifAbsent: [^false].
    ^true.!

rowForTable: aTable withKey: aKey 
    ^(self subMapForTable: aTable) at: aKey!

rowForTable: aTable withKey: aKey ifAbsent: aBlock
    ^(self subMapForTable: aTable) at: aKey ifAbsent: aBlock! !

!RowMap methodsFor: 'counting'!

numberOfEntries
    ^rowDictionary inject: 0 into: [:sum :each | sum + each size]!

numberOfEntriesForTable: aTable
    ^(self subMapForTable: aTable) size.! !

!RowMap methodsFor: 'iterating'!

keysAndValuesDo: aBlock 
    self tables do: [:each | 
    	(self subMapForTable: each) keysAndValuesDo: aBlock].!

objects
    | objects |
    objects := IdentitySet new.
    self tables do: [:each | objects addAll: (self subMapForTable: each) keys].
    ^objects!

objectsAndRowsDo: aTwoArgumentBlock 
    rowDictionary do: [:eachObjectToRowDictionary | eachObjectToRowDictionary keysAndValuesDo: aTwoArgumentBlock].!

objectsAndRowsForTable: aTable do: aTwoArgumentBlock 
    ^(self subMapForTable: aTable) keysAndValuesDo: aTwoArgumentBlock!

rowsDo: aBlock 
    self tables do: [:each | self rowsForTable: each do: aBlock]!

rowsForTable: aTable do: aBlock 
    ^(self subMapForTable: aTable) do: aBlock! !

!RowMap methodsFor: 'set operations'!

additiveDifferencesFrom: aRowMap into: differencesMap
    self objectsAndRowsDo: [:object :row |
    	| correspondingRow |
    	correspondingRow := aRowMap
    		rowForTable: row table
    		withKey: object
    		ifAbsent: [DatabaseRow new].
    	(row equals: correspondingRow)
    		ifFalse:
    			[differencesMap
    				addRow: (row withAllFieldsIn: correspondingRow)
    				forTable: row table
    				withKey: object]].!

differenceFrom: aRowMap
    | differencesMap |
    differencesMap := RowMap new.
    self	additiveDifferencesFrom: aRowMap into: differencesMap.
    self	subtractiveDifferencesFrom: aRowMap into: differencesMap.
    ^differencesMap.!

subtractiveDifferencesFrom: aRowMap into: differencesMap
    "Figure out which things are in aRowMap but not in us. These should be flagged as delete rows"

    aRowMap
    	objectsAndRowsDo:
    		[:object :row | 
    		| adjustedObject |
    		adjustedObject := (aRowMap reverseLookup: object).
    		self
    			rowForTable: row table
    			withKey: adjustedObject
    			ifAbsent:
    				[row forDeletion: true.
    				differencesMap
    					addRow: row
    					forTable: row table
    					withKey: adjustedObject]].! !

!RowMap methodsFor: 'tests'!

isEmpty
    self rowsDo: [:each | ^false].
    ^true!

notEmpty
    ^self isEmpty not! !

!RowMap methodsFor: 'initialize/release'!

initialize
    rowDictionary := IdentityDictionary new! !

!RowMap class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!RowMap class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseType methodsFor: 'testing'!

hasParameters
    "Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"
    ^false.!

hasSequence
    ^false.!

isGenerated
    ^false!

isStringType
    "Return true if the type of values this stores are strings"
    ^false.!

isVariable
    ^false.!

isVariableWidth
    "Return true if this type allows varying length data within a particular instance. e.g., this is true for a varchar, but false for a fixed size character field"
    ^false.! !

!DatabaseType methodsFor: 'SQL'!

platform
    ^platform!

platform: aDatabasePlatform
    platform := aDatabasePlatform.!

postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow!
postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession!
preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession!
print: aValue on: aStream
    aValue glorpPrintSQLOn: aStream.!

printCollection: aCollection on: aStream
    aCollection glorpPrintSQLOn: aStream for: self.!

typeString
    ^typeString.! !

!DatabaseType methodsFor: 'accessing'!

precision: anInteger
    ^self error: ((self class name asString), ' is not a variable precision type.')!

scale: anInteger
    ^self error: ((self class name asString), ' is not a variable scale type.')!

size: anInteger
    ^self error: ((self class name asString), ' is not a variable sized type.')!

typeString: aString
    typeString := aString! !

!DatabaseType methodsFor: 'initialize'!

initialize!
initializeForField: aDatabaseField in: aDescriptorSystem! !

!DatabaseType methodsFor: 'converting'!

converterForStType: aClass
    ^self platform nullConverter.!

impliedSmalltalkType
    "Return the Smalltalk type which most commonly corresponds to our database type. By default, Object if we don't have any more specific information."
    ^Object.! !

!DatabaseType class methodsFor: 'instance creation'!

instance
    ^super new!

new
    ^super new initialize.! !

!DatabaseType class methodsFor: 'printing'!

padToTwoDigits: anInteger
    | string |
    string := anInteger printString.
    ^string size = 1 ifTrue: ['0', string] ifFalse: [string].! !

!DatabaseType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TimeStampType methodsFor: 'converting'!

converterForStType: aClass
    ^self platform converterNamed: #timestamp.!

impliedSmalltalkType
    ^Dialect timestampClass.! !

!TimeStampType methodsFor: 'SQL'!

print: aValue on: aStream
    aStream nextPutAll: (self platform printTimestamp: aValue for: self).! !

!TimeStampType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!InMemorySequenceDatabaseType methodsFor: 'converting'!

impliedSmalltalkType
    ^Integer.! !

!InMemorySequenceDatabaseType methodsFor: 'initialize-release'!

representedBy: dbType
    representationType := dbType! !

!InMemorySequenceDatabaseType methodsFor: 'testing'!

isGenerated
    ^true! !

!InMemorySequenceDatabaseType methodsFor: 'SQL'!

preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession
    aDatabaseRow at: aDatabaseField put: (self class next)!

typeString
    ^representationType typeString! !

!InMemorySequenceDatabaseType class methodsFor: 'accessing'!

next
    (Count isNil)
    ifTrue: [Count := 0].
    Count := Count + 1.
    ^Count!

reset
    Count := 0! !

!InMemorySequenceDatabaseType class methodsFor: 'instance creation'!

representedBy: dbType
    ^super new
    	representedBy: dbType! !

!InMemorySequenceDatabaseType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AbstractNumericType methodsFor: 'converting'!

impliedSmalltalkType
    ^Number.! !

!AbstractNumericType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AbstractStringType methodsFor: 'testing'!

hasParameters
    "Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"
    ^true.!

isStringType
    ^true.! !

!AbstractStringType methodsFor: 'accessing'!

width
    ^width.!

width: anInteger
    width := anInteger! !

!AbstractStringType methodsFor: 'converting'!

converterForStType: aClass
    (aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToStringTF].
    (aClass includesBehavior: Symbol) ifTrue: [^self platform converterNamed: #symbolToString].
    width isNil ifFalse: [
    	(aClass includesBehavior: String) ifTrue: [^self platform converterNamed: #stringToString]].
    ^super converterForStType: aClass.!

impliedSmalltalkType
    ^String.! !

!AbstractStringType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseRow methodsFor: 'initializing'!

fieldsAndValidValuesDo: aBlock 
    "If iterating over fields and values, we include wrappers with no value assigned yet. This might or might not be what we want. This one just iterates over ones with actual values"
    self isEmpty ifTrue: [^self].
    table fields do: [:each |  | value |
    	value := self at: each ifAbsent: [self class missingFieldIndicator].
    	value == self class missingFieldIndicator ifFalse: [
    		aBlock value: each value: value]].!

fieldsAndValuesDo: aBlock 
    table fields do: [:each | aBlock value: each value: (self at: each ifAbsent: [self class missingFieldIndicator])]!

initialize
    contents := IdentityDictionary new.
    shouldBeWritten := true.
    forDeletion := false.! !

!DatabaseRow methodsFor: 'sequencing'!

postWriteAssignSequencesUsing: aSession
    self table fields do: [:each |
    	(self hasValueFor: each) ifFalse: [
    		each type postWriteAssignSequenceValueFor: each in: self using: aSession]].!

preWriteAssignSequencesUsing: aSession 
    self table fields do: 
    		[:each | 
    		(self hasValueFor: each) 
    			ifFalse: 
    				[each type 
    					preWriteAssignSequenceValueFor: each
    					in: self
    					using: aSession]]! !

!DatabaseRow methodsFor: 'querying'!

hasValueFor: aField
    ^(self wrapperAt: aField ifAbsent: [^false]) hasValue.!

shouldBeWritten
    ^shouldBeWritten! !

!DatabaseRow methodsFor: 'enumerating'!

fieldsDo: aBlock 
    contents keysDo: [:each | aBlock value: each]!

fieldValuesDo: aBlock 
    contents do: aBlock.!

keysAndValuesDo: aBlock
    contents keysAndValuesDo: [:eachKey :eachValue |
    	aBlock value: eachKey value: eachValue contents].! !

!DatabaseRow methodsFor: 'accessing'!

at: aField
    ^self at: aField ifAbsent: [self error: 'missing field'].!

at: aField ifAbsent: absentBlock
    ^(self wrapperAt: aField ifAbsent: [^absentBlock value]) contents.!

at: aField put: aValue 
    
    "For generated fields, we expect the real value to be provided later by the database, so don't write a nil value"

    
    | wrapper |
    aValue isGlorpExpression ifTrue: [self error: 'cannot store expressions in rows'].
    aField table == self table ifFalse: [self error: 'Invalid table'].
    wrapper := contents at: aField ifAbsentPut: [FieldValueWrapper new].
    (aValue isNil and: [aField isGenerated]) ifFalse: [wrapper contents: aValue].
    ^wrapper.!

atFieldNamed: aString
    | field |
    field := table fieldNamed: aString.
    ^self at: field!

atFieldNamed: aString put: anObject
    | field |
    field := table fieldNamed: aString.
    ^self at: field put: anObject!

fields
    ^contents keys.!

forDeletion
    ^forDeletion.!

forDeletion: aBoolean
    forDeletion := aBoolean.!

includesField: aField
    ^contents includesKey: aField.!

nonGeneratedFieldsWithValues
    "Return a list of our fields that a) are not generated or b) have values. That is, exclude values we expect the database to generate"
    | result |
    result := OrderedCollection new: contents size.
    self fieldsAndValidValuesDo: [:field :value | 
    	(value notNil or: [field isGenerated not]) ifTrue: [result add: field]].
    ^result.!

nonPrimaryKeyFields
    | result |
    result := OrderedCollection new: contents size.
    self fieldsDo: [:field | 
    	field isPrimaryKey ifFalse: [result add: field]].
    ^result.!

numberOfFields
    ^contents size.!

owner
    ^owner.!

owner: anObject
    owner := anObject.!

primaryKey
    | |
    self table primaryKeyFields isEmpty ifTrue: [^nil].
    ^self table hasCompositePrimaryKey 
    	ifTrue: [
    		self table primaryKeyFields 
    			collect: [:each | 	self at: each]]
    	ifFalse: [self at: self table primaryKeyFields first].!

table
    "Private - Answer the value of the receiver's ''table'' instance variable."

    ^table!

wrapperAt: aField
    ^self wrapperAt: aField ifAbsent: [self error: 'Field not found'].!

wrapperAt: aField ifAbsent: aBlock
    ^contents at: aField ifAbsent: aBlock.!

wrapperAt: aField put: aWrapper
    "Slightly wacky code to try and run faster"
    | old inserted |
    inserted := false.
    old := contents at: aField ifAbsentPut: [inserted := true. aWrapper].
    inserted not and: [old == aWrapper ifTrue: [^self]].
    inserted ifFalse: [contents at: aField put: aWrapper].
    aWrapper isNowContainedBy: self and: aField.! !

!DatabaseRow methodsFor: 'printing'!

equalityStringForField: aDatabaseField
    | stream |
    stream := WriteStream on: (String new: 50).
    self printEqualityStringForField: aDatabaseField on: stream.
    ^stream contents.!

printEqualityStringForField: aDatabaseField on: aStream 
    "Get around PostgreSQL bug.  Qualified names cannot appear in SET expression."
    aDatabaseField printNameOn: aStream withParameters: #().
    aStream nextPutAll: ' = '.
    self printValueOfField: aDatabaseField on: aStream!

printEqualityTemplateForField: aDatabaseField on: aCommand
    "Get around PostgreSQL bug.  Qualified names cannot appear in SET expression."
    | bind |
    aDatabaseField printNameOn: aCommand withParameters: #().
    aCommand nextPutAll: ' = '.
    bind := aCommand canBind: (self at: aDatabaseField) to: aDatabaseField type.
    bind
    	ifTrue: [aCommand nextPutAll: '?']
    	ifFalse: [self printValueOfField: aDatabaseField on: aCommand].!

printEqualityTemplateForField: aDatabaseField on: aStream withBinding: aBoolean
    "Get around PostgreSQL bug.  Qualified names cannot appear in SET expression."
    aDatabaseField printNameOn: aStream withParameters: #().
    aStream nextPutAll: ' = '.
    aBoolean 
    	ifTrue: [aStream nextPutAll: '?']
    	ifFalse: [self printValueOfField: aDatabaseField on: aStream].!

printFieldNamesOn: aWriteStream 
    GlorpHelper 
    	do: [:each | aWriteStream nextPutAll: each name]
    	for: self table fields
    	separatedBy: [aWriteStream nextPutAll: ','].!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '(' , (table name isNil ifTrue: [''] ifFalse: [table name]),  ')'.
    aStream nl.
    contents keysAndValuesDo: [:eachField :eachWrapper |
    	aStream nextPutAll: '    '.
    	eachField printOn: aStream.
    	aStream nextPutAll: '->'.
    	eachWrapper printOn: aStream.
    	aStream nl.].!

printPrimaryKeyStringOn: aStream 
    "If there is no primary key (i.e. this is a link table) use all the values that we have"
    | fields |
    fields := table primaryKeyFields isEmpty 
    	ifTrue: [contents keys]
    	ifFalse: [table primaryKeyFields].
    GlorpHelper
    	do:  [:eachField |
    		self printEqualityStringForField: eachField on: aStream]
    	for: fields
    	separatedBy: [aStream nextPutAll: ' AND '].!

printPrimaryKeyTemplateOn: aStream
    "If there is no primary key (i.e. this is a link table) use all the values that we have"
    | fields |
    fields := table primaryKeyFields isEmpty 
    	ifTrue: [contents keys]
    	ifFalse: [table primaryKeyFields].
    GlorpHelper
    	do:  [:eachField |
    		self printEqualityTemplateForField: eachField on: aStream]
    	for: fields
    	separatedBy: [aStream nextPutAll: ' AND '].!

printValueOfField: aDatabaseField on: aWriteStream 
    aDatabaseField type print: (self at: aDatabaseField) on: aWriteStream.! !

!DatabaseRow methodsFor: 'configuring'!

shouldBeWritten: aBoolean 
    shouldBeWritten := aBoolean!

table: anObject
    "Private - Set the value of the receiver's ''table'' instance variable to the argument, anObject."

    table := anObject!

withAllFieldsIn: aRow
    "aRow represents our original state. Make sure that we have all the fields in aRow, using nil values for any that are missing. This is needed if, e.g. we have been removed from a 1-many relationship, so we don't get a value generated for our foreign key, but we should still write it as a nil. We have to distinguish this from the case of a value that simply hasn't changed."
    aRow isEmpty ifTrue: [^self].
    self numberOfFields = table fields size ifTrue: [^self].
    aRow fieldsAndValidValuesDo: [:eachField :eachValue |
    		(self includesField: eachField) ifFalse: [
    			self at: eachField put: nil]].! !

!DatabaseRow methodsFor: 'testing'!

equals: aRow 
    self fieldsAndValuesDo: 
    		[:eachField :eachWrapper | 
    		| otherValue |
    		otherValue := aRow at: eachField ifAbsent: [self class missingFieldIndicator].
    		eachWrapper = otherValue ifFalse: [^false]].
    ^true!

isEmpty
    ^contents isEmpty.! !

!DatabaseRow class methodsFor: 'instance creation'!

new
    ^super new initialize.!

newForTable: aTable
    ^self new table: aTable.!

newForTable: aTable withOwner: anObject
    ^self new table: aTable; owner: anObject.! !

!DatabaseRow class methodsFor: 'private'!

missingFieldIndicator
    missingFieldIndicator == nil ifTrue: [missingFieldIndicator := Object new].
    ^missingFieldIndicator.! !

!DatabaseRow class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TimeType methodsFor: 'SQL'!

print: aValue on: aStream
    aStream nextPutAll: (self platform printTime: aValue for: self).! !

!TimeType methodsFor: 'conversion-times'!

converterForStType: aClass
    ^self platform converterNamed: #time.! !

!TimeType methodsFor: 'converting'!

impliedSmalltalkType
    ^Time.! !

!TimeType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!NumericType methodsFor: 'SQL'!

typeString
    | w |
    platform supportsVariableSizedNumerics ifFalse: [^typeString].
    w := WriteStream on: String new.
    w nextPutAll: typeString.
    precision isNil 
    	ifFalse: 
    		[w nextPutAll: '(' , precision printString.
    		scale isNil ifFalse: [w nextPutAll: ',' , scale printString].
    		w nextPutAll: ')'].
    ^w contents! !

!NumericType methodsFor: 'accessing'!

precision: anInteger
    precision := anInteger.!

scale: anInteger
    scale := anInteger.! !

!NumericType methodsFor: 'initialize'!

initialize
    super initialize.
    typeString := 'numeric'.! !

!NumericType methodsFor: 'testing'!

hasParameters
    "Return true if this has modifiable parameters. That is, when we return one of these, should we return a copy rather than trying to save space be re-using instances"
    ^true.! !

!NumericType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Query methodsFor: 'accessing'!

collectionType
    "Note that queries default the collection type to array, while mappings default to OrderedCollection. I think it makes sense"
    collectionType isNil ifTrue: [collectionType := Array].
    ^collectionType.!

collectionType: aClass
    collectionType := aClass.!

expectedRows
    "How many rows do we think it's likely this query will bring back. Used for tweaking things like block factor"
    ^expectedRows isNil
    	ifTrue: [expectedRows := self readsOneObject ifTrue: [1] ifFalse: [100]]
    	ifFalse: [expectedRows].!

expectedRows: anInteger
    "How many rows do we think it's likely this query will bring back. Used for tweaking things like block factor"
    expectedRows := anInteger!

readsOneObject
    self subclassResponsibility.!

session
    ^session!

session: aSession 
    session := aSession! !

!Query methodsFor: 'convenience'!

AND: anExpression
    "Allow you to send AND: or OR: directly to a query to build up a query dynamically without needing to mess with the criteria explicitly"
    criteria := (anExpression asGlorpExpressionOn: criteria ultimateBaseExpression) AND: criteria.!

OR: anExpression
    "Allow you to send AND: or OR: directly to a query to build up a query dynamically without needing to mess with the criteria explicitly"
    criteria := (anExpression asGlorpExpressionOn: criteria ultimateBaseExpression) OR: criteria.! !

!Query methodsFor: 'executing'!

executeIn: aSession
    ^self executeWithParameters:#() in: aSession.!

executeWithParameters: parameterArray in: aSession 
    self subclassResponsibility.! !

!Query methodsFor: 'initialize'!

initialize
    prepared := false.! !

!Query methodsFor: 'copying'!

postCopy
    prepared := false.
    criteria := criteria rebuildOn: BaseExpression new.! !

!Query class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Query class methodsFor: 'instance creation'!

new
    ^super new initialize.!

readManyOf: aClass
    "readManyOf: and returningManyOf: are synonyms. This now seems more natural to me, to be consistent with session API"
    ^self returningManyOf: aClass where: nil.!

readManyOf: aClass where: criteria
    ^self returningManyOf: aClass where: criteria.!

readOneOf: aClass where: criteria
    ^self returningOneOf: aClass where: criteria.!

returningManyOf: aClass
    ^self returningManyOf: aClass where: nil.!

returningManyOf: aClass where: criteria
    "Backward-compatibility, since we changed the class name."
    ^SimpleQuery returningManyOf: aClass where: criteria.!

returningOneOf: aClass where: criteria
    "Backward-compatibility, since we changed the class name."
    ^SimpleQuery returningOneOf: aClass where: criteria.! !

!FieldUnifier methodsFor: 'unifying'!

calculateRows
    rows := OrderedCollection new: fields size.
    fieldsWithRows := OrderedCollection new: fields size.
    fields with: objects do: [:eachField :eachObject |
    	eachObject isNil 
    		ifFalse: [
    			fieldsWithRows add: eachField.
    			rows add: (rowMap findOrAddRowForTable: eachField table withKey: eachObject)]].!

convertValueToDatabaseForm: aValue
    "Just a placeholder right now"
    ^aValue.!

findExistingWrappersIfNone: aBlock 
    | allWrappers |
    allWrappers := IdentitySet new: 5.
    fieldsWithRows with: rows do: [:eachField :eachRow | 
    	| wrapper |
    	wrapper := eachRow wrapperAt: eachField ifAbsent: [nil].
    	wrapper isNil ifFalse: [allWrappers add: wrapper]].
    ^allWrappers isEmpty
    	ifTrue: [aBlock value]
    	ifFalse: [allWrappers asArray].!

findWrapperToUseFrom: aWrapperCollection
    | wrappersWithValues winner |
    wrappersWithValues := aWrapperCollection select: [:each | each hasValue].
    wrappersWithValues size > 1
    	ifTrue:
    		[(wrappersWithValues
    			allSatisfy: [:each | each contents = wrappersWithValues first contents])
    			ifFalse: [self error: 'Conflicting values in rows']].
    winner := wrappersWithValues size = 1
    	ifTrue: [wrappersWithValues at: 1]
    	ifFalse: [aWrapperCollection first].
    ^winner.!

handleConstantCase
    "It may turn out that the first field is really a constant value. If so, just set it rather than establishing a constraint"
    | value field row |
    value := self convertValueToDatabaseForm: (fields at: 1).
    field := fields at: 2.
    row := rowMap findOrAddRowForTable: field table withKey: (objects at: 2).
    row at: field put: value value.!

unify
    |  wrappers |
    self isReallyJustAConstant ifTrue: [^self handleConstantCase].
    rowMap adjustForMementos: objects.
    self calculateRows.
    wrappers := self findExistingWrappersIfNone: [Array with: FieldValueWrapper new].
    self unifyWrappers: wrappers.!

unifyWrappers: aWrapperCollection 
    | winner |
    winner := self findWrapperToUseFrom: aWrapperCollection.
    aWrapperCollection do: 
    		[:eachWrapper | 
    			eachWrapper == winner ifFalse: [
    				eachWrapper containedBy keysAndValuesDo: [:eachRow :eachListOfFields |
    					eachListOfFields do: [:eachField |
    						eachRow wrapperAt: eachField put: winner]]]].
    fieldsWithRows with: rows
    	do: [:eachField :eachRow | eachRow wrapperAt: eachField put: winner]! !

!FieldUnifier methodsFor: 'testing'!

isConstant: anObject
    
    ^(anObject class == DatabaseField) not.!

isReallyJustAConstant
    "Return true if what we're being asked to handle includes a constant value, so it doesn't require a constraint at all, just setting a value. We know that constants are only permissible as the source field entry"

    ^(self isConstant: fields first)! !

!FieldUnifier methodsFor: 'accessing'!

fields
    ^fields!

fields: anObject
    fields := anObject!

objects
    ^objects!

objects: anObject
    objects := anObject!

rowMap
    ^rowMap!

rowMap: anObject
    rowMap := anObject! !

!FieldUnifier class methodsFor: 'instance creation'!

unifyFields: fields correspondingTo: objects in: aRowMap 
    "We are given fields and objects corresponding to an object relationships. So, e.g. if a Person has a Car, and the table PERSON.CAR_ID should equal CAR.ID, then we will have (PERSON.CAR_ID, CAR.ID) and (aPerson, aCar). Establish in our rowmap that these two fields are equal."	
    ((self new)
    	fields: fields;
    	objects: objects;
    	rowMap: aRowMap) unify! !

!FieldUnifier class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Descriptor methodsFor: 'accessing'!

addMapping: aMapping 
    mappings add: aMapping.
    aMapping descriptor: self.
    aMapping updateUseDirectAccess.
    mappedFields := nil!

addMultipleTableCriteria: anExpression 
    self multipleTableCriteria add: anExpression!

addTable: aDatabaseTable 
    tables add: aDatabaseTable.!

allMappingsForField: aField 
    "Return all of the mappings that use this field"
    ^mappings select: [:each | each mappedFields includes: aField]!

cachePolicy
    cachePolicy isNil ifTrue: [^system cachePolicy].
    ^cachePolicy!

cachePolicy: aCachePolicy
    cachePolicy:= aCachePolicy!

describedClass
    "Private - Answer the value of the receiver's ''describedClass'' instance variable."

    ^describedClass!

describedClass: anObject
    "Private - Set the value of the receiver's ''describedClass'' instance variable to the argument, anObject."

    describedClass := anObject!

directMappingForField: aField 
    "Return a single, direct mapping for this field. There may conceivably be more than one, but they all have to agree, so it shouldn't matter as far as the value. There may also be none."

    ^mappings 
    	detect: [:each | each isRelationship not and: [each mappedFields includes: aField]]
    	ifNone: [nil]!

fieldsForSelectStatement
    | myFields inheritedFields |
    myFields := self mappedFields.
    inheritedFields := self typeResolver fieldsForSelectStatement.
    ^inheritedFields isEmpty ifTrue: [myFields] ifFalse: [myFields, inheritedFields].!

initialize
    mappings := OrderedCollection new.
    tables := OrderedCollection new: 1.!

mappedFields
    "Return all the fields that are mapped, in the order that they occur in the table."
    mappedFields isNil ifTrue: [
    	| fieldSet |
    	fieldSet := IdentitySet new: mappings size.
    	mappings do: [:each | fieldSet addAll: each mappedFields].
    	mappedFields := OrderedCollection new.
    	tables do: [:each |
    		each fields do: [:eachField | (fieldSet includes: eachField) ifTrue: [mappedFields add: eachField]]]].
    ^mappedFields.!

mappingForAttributeNamed: aSymbol
    ^mappings detect: [:each | each attributeName == aSymbol] ifNone: [nil]!

multipleTableCriteria
    multipleTableCriteria isNil
    	ifTrue: [multipleTableCriteria := OrderedCollection new: 1].
    ^multipleTableCriteria.!

primaryTable
    ^tables first.!

session
    ^system session.!

system
    ^system!

system: anObject
    system := anObject!

table
    ^tables first.!

table: aDatabaseTable
    tables add: aDatabaseTable.!

tables
    ^tables!

typeMapping
    ^mappings detect: [ :each | each isTypeMapping ] ifNone: [
    	| mapping |
    	mapping := IdentityTypeMapping new.
    	self addMapping: mapping.
    	mapping]!

typeMapping: aMapping
    self addMapping: aMapping!

typeResolver
    typeResolver isNil
    	ifTrue: [  IdentityTypeResolver new register: self  ].
    ^typeResolver!

typeResolver: anObject
    typeResolver := anObject! !

!Descriptor methodsFor: 'testing'!

computeMapsPrimaryKeys
    | primaryKeyFields |
    primaryKeyFields := self primaryTable primaryKeyFields.
    primaryKeyFields isEmpty ifTrue: [^false].
    primaryKeyFields
    	do: [:each | (self mappedFields includes: each) ifFalse: [^false]].
    ^true.!

isTypeMappingRoot
    ^self typeResolver isTypeMappingRoot: self!

mapsPrimaryKeys
    mapsPrimaryKeys isNil ifTrue: [mapsPrimaryKeys := self computeMapsPrimaryKeys].
    ^mapsPrimaryKeys!

supportsOrdering
    typeResolver isNil ifTrue: [^true].
    ^typeResolver class ~= HorizontalTypeResolver.! !

!Descriptor methodsFor: 'mapping'!

createDeleteRowFor: anObject table: aTable in: aRowMap
    "Create records for rows that require deletion"

    aTable primaryKeyFields do: [:each |
    	(self directMappingForField: each) mapFromObject: anObject intoRowsIn: aRowMap].!

createDeleteRowsFor: anObject in: aRowMap
    "Create records for rows that require deletion"

    |  |
    anObject class == self describedClass ifFalse: [self error: 'wrong descriptor for this object'].
    self tables do: [:eachTable |
    	self createDeleteRowFor: anObject table: eachTable in: aRowMap.
    	(aRowMap rowForTable: eachTable withKey: anObject) forDeletion: true].
    "It's possible that we might not have any direct mapping for a secondary table's primary keys, so 
allow the multiple table criteria to specify them if that's the only one. If they're not, then they don't do any harm"
    self multipleTableCriteria do: [:each |
    	each mapFromSource: anObject andTarget: anObject intoRowsIn: aRowMap].!

createRowsFor: anObject in: aRowMap
    |  |
    anObject class == self describedClass ifFalse: [self error: 'wrong descriptor for this object'].
    mappings do: [:each |
    	each mapFromObject: anObject intoRowsIn: aRowMap].
    self multipleTableCriteria do: [:each |
    	each mapFromSource: anObject andTarget: anObject intoRowsIn: aRowMap].!

mappings
    ^ReadStream on: mappings!

populateObject: anObject inBuilder: anElementBuilder
    "Answer an object using the values for the specified fields."

    mappings
    	do: [:each | each mapObject: anObject inElementBuilder: anElementBuilder].!

primaryKeyExpressionFor: anObject
    | expression |
    anObject class == describedClass ifFalse: [self error: 'Wrong descriptor for this object'].
    expression := nil.
    self primaryKeyMappings do: [:each | 
    	| clause |
    	clause := each expressionFor: anObject.
    	expression := clause AND: expression].
    ^expression.!

primaryKeyFor: anObject
    | result |
    anObject class == describedClass ifFalse: [self error: 'Wrong descriptor for this object'].
    result := self primaryKeyMappings collect: [:each | 
    	each getValueFrom: anObject].
    ^result size = 1 ifTrue: [result at: 1] ifFalse: [result].!

primaryKeyMappings
    ^self primaryTable primaryKeyFields 
    	collect: [:each | self directMappingForField: each]!

readBackNewRowInformationFor: anObject in: aRowMap 
    anObject class == self describedClass ifFalse: [self error: 'wrong descriptor for this object'].
    mappings do: [:each | each readBackNewRowInformationFor: anObject fromRowsIn: aRowMap]! !

!Descriptor methodsFor: 'internal'!

describedConcreteClassFor: row withBuilder: builder
    "Lookup the class that is represented by the row when there is a possibility
    	of this row representing any class within a hierarchy. "
    ^self typeResolver describedConcreteClassFor: row withBuilder: builder descriptor: self!

readBackNewRowInformationFor: anObject!
referencedIndependentObjectsFrom: anObject do: aBlock
    mappings do: [:each |
    	(each referencedIndependentObjectsFrom: anObject) do: [:eachReferencedObject |
    		aBlock value: eachReferencedObject]].!

referencedIndependentObjectsWithMappingsFrom: anObject do: aBlock
    mappings do: [:each |
    	(each referencedIndependentObjectsFrom: anObject) do: [:eachReferencedObject |
    		aBlock value: eachReferencedObject value: each]].! !

!Descriptor methodsFor: 'type resolution'!

classesRequiringIndependentQueries
    ^ self typeResolver classesRequiringIndependentQueriesFor: self describedClass!

typeMappingRoot
    ^self typeResolver typeMappingRoot!

typeMappingRootDescriptor
    ^self typeResolver typeMappingRootDescriptor! !

!Descriptor methodsFor: 'type mapping'!

allDescribedConcreteClasses
    ^ self typeMapping allDescribedConcreteClasses!

registerTypeResolver: aResolver
    self registerTypeResolver: aResolver abstract: false!

registerTypeResolver: aResolver abstract: shouldBeAbstract
    shouldBeAbstract ifFalse: [ self beAbstract ].
    aResolver register: self.!

typeMappingCriteriaIn: base
    | r l |
    r := ConstantExpression for: self typeMapping keys.
    l := FieldExpression forField: self typeMapping field basedOn: base.
    ^l in: r! !

!Descriptor methodsFor: 'tracing'!

defaultTracing
    ^Tracing new.!

setupTracing: aTracing
    "Find all the other objects that need to be read when this one is read"

    self trace: aTracing context: aTracing base.!

trace: aTracing context: anExpression
    "For each mapping, check if the relationship is involved in the set of things
to be read"
    mappings do: [:each |
    	each trace: aTracing context: anExpression].! !

!Descriptor methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '('.
    describedClass printOn: aStream.
    aStream nextPutAll: ')'.! !

!Descriptor class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!Descriptor class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DateType methodsFor: 'SQL'!

print: aValue on: aStream
    aStream nextPutAll: (self platform printDate: aValue for: self).! !

!DateType methodsFor: 'converting'!

converterForStType: aClass
    ^self platform converterNamed: #date.!

impliedSmalltalkType
    ^Date.! !

!DateType methodsFor: 'initialize'!

initialize
    super initialize.
    typeString := 'date'! !

!DateType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TimedExpiryCachePolicy methodsFor: 'wrap/unwrap'!

cacheEntryFor: anObject
    ^Array with: self totalSeconds with: anObject.!

contentsOf: aCacheEntry
    ^aCacheEntry at: 2.!

hasExpired: aCacheEntry
    ^(self totalSeconds - (aCacheEntry at: 1)) >= timeout.!

markEntryAsCurrent: aCacheEntry in: aCache
    aCacheEntry at: 1 put: self totalSeconds.! !

!TimedExpiryCachePolicy methodsFor: 'accessing'!

timeout
    ^timeout!

timeout: anInteger
    timeout := anInteger! !

!TimedExpiryCachePolicy methodsFor: 'initialize'!

initialize
    super initialize.
    timeout := 300.! !

!TimedExpiryCachePolicy methodsFor: 'utility'!

totalSeconds
    ^Dialect totalSeconds.! !

!TimedExpiryCachePolicy class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AbstractReadQuery methodsFor: 'executing'!

executeWithParameters: parameterArray in: aSession 
    | cacheHit |
    session := aSession.
    self requiresFullQuery 
    	ifTrue: [^self asFullQuery executeWithParameters: parameterArray in: aSession].

    self checkValidity.
    self setUpCriteria.
    self hasTracing ifFalse: [
    	"We only need to do the cache hit if we're a simple query without a parent. How do we tell, better than not having been given a tracing?"
    	cacheHit := self checkCacheWithParameters: parameterArray.
    	cacheHit isNil ifFalse: [^cacheHit]].
    self setupTracing.
    ^self 
    	readFromDatabaseWithParameters: parameterArray.!

setUpCriteria
    criteria := criteria asGlorpExpressionForDescriptor: (session descriptorFor: resultClass).
    ordering isNil ifFalse: [
    	ordering := ordering collect: [:each |
    		(self expressionBlockFor: each) asGlorpExpressionOn: criteria ultimateBaseExpression]].
    tracing isNil ifFalse: [tracing updateBase: criteria ultimateBaseExpression].!

validateCriteria
    criteria isPrimaryKeyExpression ifFalse: [
    	criteria do: [:each | each validate]].! !

!AbstractReadQuery methodsFor: 'accessing'!

absentBlock
    absentBlock == nil ifTrue: [^[nil]].
    ^absentBlock.!

baseExpression
    ^criteria ultimateBaseExpression.!

criteria
    ^criteria!

defaultTracing
    | defaultTracing |
    defaultTracing := Tracing new.
    defaultTracing base: criteria ultimateBaseExpression.
    ^defaultTracing.!

descriptor
    ^session descriptorFor: resultClass.!

readsOneObject
    ^readsOneObject.!

readsOneObject: aBoolean 
    readsOneObject := aBoolean!

resultClass
    ^resultClass!

returnProxies
    ^returnProxies!

returnProxies: aBoolean
    returnProxies := aBoolean!

shouldRefresh
    ^shouldRefresh!

shouldRefresh: aBoolean
    shouldRefresh := aBoolean!

tracing
    tracing isNil ifTrue: [tracing := self defaultTracing].
    ^tracing.!

tracing: aTracing
    tracing := aTracing.
    tracing updateBase: criteria ultimateBaseExpression.
    tracing setup.! !

!AbstractReadQuery methodsFor: 'validation'!

checkValidity
    resultClass isBehavior ifFalse: [self error: 'resultClass must be a class'].
    (ordering notNil and: [self descriptor supportsOrdering not]) ifTrue: [self error: 'The descriptor for ', self resultClass name, ' does not support ordering in queries'].! !

!AbstractReadQuery methodsFor: 'testing'!

hasTracing
    "Return true if we've given this query a tracing already"
    ^false.! !

!AbstractReadQuery methodsFor: 'ordering'!

expressionBlockFor: anOrderingCriteria
    "Allow us to use symbols interchangeably with simple blocks for ordering, so 
    #firstName is equivalent to [:each | each firstName]. Also, allow chains of symbols, so #(owner firstName)"

    anOrderingCriteria isGlorpExpression ifTrue: [^anOrderingCriteria].

    "Sometimes the inability to portably and efficiently test this sort of thing gets on my nerves. Note that if you step through this expression (F6) in VW 7.1 it won't work."
    "anOrderingCriteria is a block ..."
    anOrderingCriteria class == ([] class) ifTrue: [^anOrderingCriteria].

    anOrderingCriteria isSymbol 
    	ifTrue: [^[:each | each perform: anOrderingCriteria]].
    
    "otherwise, we assume it's a collection of symbols, the only other valid case"
    anOrderingCriteria do: [:each | each isSymbol ifFalse: [self error: 'invalid ordering criteria']].
    ^[:each | anOrderingCriteria inject: each into: [:sum :eachExpression |
    	sum perform: eachExpression]].!

orderBy: aBlock
    ordering isNil 
    	ifTrue: [ordering := Array with: aBlock]
    	ifFalse: [ordering := ordering , (Array with: aBlock)].!

ordering
    ^ordering.!

setOrdering: aCollection
    ordering := aCollection.! !

!AbstractReadQuery methodsFor: 'specifying retrievals'!

alsoFetch: anExpression
    self tracing alsoFetch: anExpression.!

retrieve: anExpression
    self tracing retrieve: anExpression.! !

!AbstractReadQuery methodsFor: 'caching'!

checkCacheWithParameters: aDictionary 
    | primaryKey |
    readsOneObject ifFalse: [^nil].
    self shouldRefresh ifTrue: [^nil].
    primaryKey := self primaryKeyFrom: aDictionary.
    primaryKey isNil ifTrue: [^nil].
    "If it's expired, make sure we do the read but still refresh"
  	(session hasExpired: resultClass key: primaryKey) ifTrue: [
    	self shouldRefresh: true.
    	^nil].
    ^session 
    	cacheAt: primaryKey
    	forClass: resultClass
    	ifNone: [nil]!

primaryKeyFrom: aDictionary 
    "Construct a primary key from the given parameters."
    aDictionary isEmpty ifTrue: [^nil].
    ^self criteria primaryKeyFromDictionary: aDictionary.! !

!AbstractReadQuery methodsFor: 'tracing'!

setupTracing
    self tracing setup.
    self tracing additionalExpressions do: [:each |
    	each hasDescriptor ifTrue: [
    		each descriptor trace: self tracing context: each]].! !

!AbstractReadQuery methodsFor: 'initialize'!

initialize
    
    super initialize.
    returnProxies := false.
    shouldRefresh := false.!

initResultClass: aClass criteria: theCriteria singleObject: aBoolean 
    resultClass := aClass.
    criteria := (theCriteria isNil or: [theCriteria = true or: [theCriteria = false]]) ifTrue: [EmptyExpression on: theCriteria] ifFalse: [theCriteria asGlorpExpression].
    readsOneObject := aBoolean.! !

!AbstractReadQuery methodsFor: 'copying'!

postCopy
    super postCopy.
    session isNil ifFalse: [self setUpCriteria].! !

!AbstractReadQuery class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AbstractReadQuery class methodsFor: 'instance creation'!

returningManyOf: aClass
    ^self new
    	initResultClass: aClass criteria: nil singleObject: false.!

returningManyOf: aClass where: criteria
    ^self new
    	initResultClass: aClass criteria: criteria singleObject: false.!

returningOneOf: aClass where: criteria
    ^self new
    	initResultClass: aClass criteria: criteria singleObject: true.! !

!ReadQuery methodsFor: 'accessing'!

readFromDatabaseWithParameters: anArray 
    | col |
    col := OrderedCollection new.
    self descriptor classesRequiringIndependentQueries do: 
    		[:aClass | 
    		| simpleQuery result |
    		simpleQuery := self asSimpleQueryFor: aClass.
    		result := simpleQuery readFromDatabaseWithParameters: anArray.
    		simpleQuery readsOneObject 
    			ifTrue: [col add: result]
    			ifFalse: [col addAll: result]].
    ^col! !

!ReadQuery methodsFor: 'converting'!

asSimpleQueryFor: aClass
    | newQuery newCriteria |
    "Rebuild the expression, because this means a full query is being split into multiple sub-queries, e.g. for an inheritance read. The expression may get prepared differently in each case (e.g. table aliases), so we can't share"
    newCriteria := criteria rebuildOn: BaseExpression new.
    newQuery := SimpleQuery new
    	initResultClass: aClass criteria: newCriteria singleObject: readsOneObject.
    newQuery session: session.
    newQuery returnProxies: self returnProxies.
    newQuery shouldRefresh: self shouldRefresh.
    newQuery setOrdering: ordering.
    newQuery collectionType: collectionType.
    newQuery setUpCriteria.
    newQuery tracing: tracing.
    newQuery expectedRows: expectedRows.
    ^newQuery.! !

!ReadQuery methodsFor: 'testing'!

requiresFullQuery
    ^false.! !

!ReadQuery class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Join methodsFor: 'preparing'!

additionalExpressions
    ^#()!

additionalExpressionsIn: aQuery 
    ^#()!

allTablesToPrint
    ^targets inject: Set new into: [:sum :each | 
    	sum add: each table. sum].!

prepareIn: aQuery 
    "Do nothing."
    aQuery criteria: self asGeneralGlorpExpression.
    aQuery criteria prepareIn: aQuery.!

sourceForTarget: aField
    | index |
    index := targets indexOf: aField.
    index = 0 ifTrue: [^nil].
    ^sources at: index.! !

!Join methodsFor: 'initialize'!

initialize
    sources := OrderedCollection new: 2.
    targets := OrderedCollection new: 2.
    base := BaseExpression new.! !

!Join methodsFor: 'converting'!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    | sourceFieldExpression targetFieldExpression completeExpression |
    completeExpression := nil.
    sources with: targets
    	do: 	[:sourceField :targetField | 
    		sourceFieldExpression := source getField: sourceField.
    		targetFieldExpression := target getField: targetField.
    		completeExpression := (sourceFieldExpression equals: targetFieldExpression)
    					AND: completeExpression].
    ^completeExpression!

asGeneralGlorpExpression
    "Convert this to a 'normal' expression representing the same information"

    | main clause |
    main := nil.
    sources with: targets
    	do: 
    		[:eachSource :eachTarget | 
    		| srcExp targetExp |
    		srcExp := self sourceExpressionFor: eachSource.
    		targetExp := self targetExpressionFor: eachTarget.
    		"Reversing the order is important because the source is the parameter, and sql won't accept '27 = FOO' "
    		clause := targetExp equals: srcExp.
    		main := main == nil ifTrue: [clause] ifFalse: [main AND: clause]].
    ^main!

isConstant: aTarget
    "The target can be either a constant (which gets turned into a ConstantExpression) or (usually) a DatabaseField, representing a parameter to the query"
    ^(aTarget class == DatabaseField) not.!

sourceExpressionFor: source
    ^(self isConstant: source)
    	ifTrue: [source]
    	ifFalse: [base getParameter: source].!

targetExpressionFor: eachTarget 
    ^(self isConstant: eachTarget)
    	ifTrue: [eachTarget]
    	ifFalse: [(base getTable: eachTarget table) getField: eachTarget].! !

!Join methodsFor: 'accessing'!

allSourceFields
    ^sources!

allTables
    ^(targets collect: [:each | each table]) asSet.!

base: aBaseExpression
    base := aBaseExpression.!

hasDescriptor
    ^false.!

numberOfParameters
    ^sources size!

targetKeys
    ^targets.!

ultimateBaseExpression
    ^base.! !

!Join methodsFor: 'printing'!

printOn: aStream
    sources with: targets do: [:source :target |
    	aStream nextPut: $(.
    	source printSQLOn: aStream withParameters: #().
    	aStream nextPutAll: ' = '.
    	target printSQLOn: aStream withParameters: #().
    	aStream nextPutAll: ') ']!

printSQLOn: aStream withParameters: aDictionary 
    1 to: sources size
    	do: 
    		[:i | 
    		| eachTarget eachSource sourceValue |
    		eachTarget := targets at: i.
    		eachSource := sources at: i.
    		eachTarget printSQLOn: aStream withParameters: aDictionary.
    		sourceValue := (self isConstant: eachSource) ifTrue: [eachSource value] ifFalse: [aDictionary at: eachSource].
    		sourceValue isNil 
    			ifTrue: [aStream nextPutAll: ' IS NULL ']
    			ifFalse: 
    				[aStream nextPutAll: ' = '.
    				sourceValue printOn: aStream].
    		i = targets size ifFalse: [aStream nextPutAll: ' AND ']]! !

!Join methodsFor: 'primary keys'!

primaryKeyFromDictionary: aDictionary
    "Given a set of parameters, return a primary key suitable for retrieving our target. Return either a value for the key, nil for no key found, or a CompositeKey for compound keys."
    "| key |
    sources size = 1 ifTrue: [^aDictionary at: sources first ifAbsent: [nil]].

    key := CompositeKey forTable: self primaryTable.
    self fieldsDo: [:eachSource :eachTarget |  |eachValue |
    	eachValue := aDictionary at: eachSource ifAbsent: [^nil].
    	key at: eachTarget put: eachValue].
    ^key isComplete ifTrue: [key] ifFalse: [nil]."

    "Bad, bad move to try to make this work at least temporarily"
    ^aDictionary at: sources first ifAbsent: [nil]! !

!Join methodsFor: 'testing'!

isPrimaryKeyExpression
    ^true.! !

!Join methodsFor: 'api'!

addSource: aField target: anotherField 
    | value |
    value := (self isConstant: aField) 
    			ifTrue: [ConstantExpression for: aField]
    			ifFalse: [aField].
    sources add: value.
    (self isConstant: anotherField) ifTrue: [
    	self error: 'You are attempting to set a constant value as the target of a relationship. I suspect you want to set it on the source instead'].
    targets add: anotherField!

asGlorpExpression
    ^self.!

asGlorpExpressionForDescriptor: aDescriptor
    base descriptor: aDescriptor.!

mapFromSource: sourceObject andTarget: targetObject intoRowsIn: aRowMap 
    sources with: targets
    	do: 
    		[:eachSourceField :eachTargetField | 
    		FieldUnifier 
    			unifyFields: (Array with: eachSourceField with: eachTargetField)
    			correspondingTo: (Array with: sourceObject with: targetObject)
    			in: aRowMap].! !

!Join methodsFor: 'iterating'!

fieldsDo: aBlock
    sources with: targets do: aBlock.! !

!Join class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Join class methodsFor: 'instance creation'!

from: aField to: anotherField
    ^self new
    	addSource: aField target: anotherField.!

from: from1Field to: to1Field
from: from2Field to: to2Field

    ^self new
    	addSource: from1Field target: to1Field;
    	addSource: from2Field target: to2Field.!

new
    ^super new initialize.! !

!InfixFunction methodsFor: 'As yet unclassified'!

convertedStValueOf: anObject
    "This assumes that functions that do conversions have already had their effect in the database, and all we're concerned with is the fundamental data type conversion"
    ^base convertedStValueOf: anObject.! !

!InfixFunction methodsFor: 'printing'!

printSQLOn: aStream withParameters: aDictionary
    
    aStream 
    	nextPutAll: function;
    	nextPut: $(.
    base printSQLOn: aStream withParameters: aDictionary.
    aStream nextPut: $).!

printTreeOn: aStream 
    aStream
    	nextPutAll: function, '('.
    base printOn: aStream.
    aStream nextPutAll: ')'.! !

!InfixFunction methodsFor: 'preparing'!

rebuildOn: aBaseExpression 
    | rebuilt |
    rebuilt := self copy.
    rebuilt base: (base rebuildOn: aBaseExpression).
    rebuilt function: function.
    ^rebuilt.! !

!InfixFunction methodsFor: 'iterating'!

do: aBlock skipping: aSet
    "Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    base do: aBlock skipping: aSet.
    aBlock value: self.! !

!InfixFunction class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVirtualCollection methodsFor: 'accessing'!

orderBy: aBlockOrExpression
    query orderBy: aBlockOrExpression.!

size
    ^self realObjects size.! !

!GlorpVirtualCollection methodsFor: 'enumerating'!

collect: aBlock
    ^self realObjects collect: aBlock!

do: aBlock
    self realObjects do: aBlock.!

reject: aBlock
    ^self copy AND: [:each | (aBlock value: each) not].!

select: aBlock
    ^self isInstantiated ifTrue: [self realObjects select: aBlock] ifFalse: [self copy AND: aBlock].! !

!GlorpVirtualCollection methodsFor: 'copying'!

postCopy
    query := query copy.
    realObjects := nil.! !

!GlorpVirtualCollection methodsFor: 'testing'!

isEmpty
    ^self realObjects isEmpty.!

isInstantiated
    ^realObjects notNil.! !

!GlorpVirtualCollection methodsFor: 'private'!

AND: aBlock
    query AND: aBlock.!

readOnlyError
    self error: 'Virtual collections are read-only'.!

realObjects
    realObjects isNil ifTrue: [	realObjects := session execute: query].
    ^realObjects.! !

!GlorpVirtualCollection methodsFor: 'adding'!

add: newObject
    self readOnlyError.! !

!GlorpVirtualCollection methodsFor: 'initialize-release'!

on: aClass in: aSession
    query := Query returningManyOf: aClass.
    session := aSession.! !

!GlorpVirtualCollection methodsFor: 'printing'!

printOn: aStream
    self isInstantiated
    	ifTrue: [super printOn: aStream]
    	ifFalse:
    		[aStream nextPutAll: 'a virtual collection of '.
    		query notNil ifTrue: [aStream nextPutAll: query resultClass name]].! !

!GlorpVirtualCollection methodsFor: 'removing'!

remove: oldObject ifAbsent: anExceptionBlock
    self readOnlyError.! !

!GlorpVirtualCollection class methodsFor: 'instance creation'!

on: aClass in: aSession
    ^self new on: aClass in: aSession.! !

!TypeResolver methodsFor: 'type resolution'!

fieldsForSelectStatement
    "Return fields that are needed in a select statement - i.e. return all inherited fields that are part of the tables we are already selecting for this object"
    ^#().!

typeMappingRootDescriptor
    self subclassResponsibility! !

!TypeResolver methodsFor: 'accessing'!

addMember: aDescriptor
    members isNil ifTrue: [ members := OrderedCollection new].
    members add: aDescriptor!

classesRequiringIndependentQueriesFor: aClass
    self subclassResponsibility!

describedConcreteClassFor: row withBuilder: builder descriptor: aDescriptor
    self subclassResponsibility!

system
    ^system!

system: anObject
    system := anObject! !

!TypeResolver methodsFor: 'registering'!

register: aDescriptor
    ^self register: aDescriptor abstract: false!

register: aDescriptor abstract: abstract
    self system: aDescriptor system.
    self addMember: aDescriptor.
    aDescriptor typeResolver: self! !

!TypeResolver methodsFor: 'other'!

describedClasses
    ^members collect: [:each | each describedClass ].! !

!TypeResolver class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!BasicTypeResolver methodsFor: 'private'!

allDescribedConcreteClasses
    self subclassDescriptorsBuilt ifFalse: [self forceSubclassDescriptorLoads].
    ^self concreteMembers collect: [ :each | each describedClass ]!

forceSubclassDescriptorLoads
    self rootClass allSubclassesDo: [ :each | self system descriptorFor: each ].
    subclassDescriptorsBuilt := true! !

!BasicTypeResolver methodsFor: 'accessing'!

concreteMembers
    ^concreteMembers isNil 
    	ifTrue: [ concreteMembers := OrderedCollection new ]
    	ifFalse: [ concreteMembers]!

rootClass
    ^rootClass!

rootClass: anObject
    rootClass := anObject!

rootDescriptor
    ^rootDescriptor isNil
    	ifTrue: [ rootDescriptor := self system descriptorFor: self rootClass ]
    	ifFalse: [ rootDescriptor ]!

subclassDescriptorsBuilt
    ^subclassDescriptorsBuilt isNil
    	ifTrue: [ subclassDescriptorsBuilt := false ]
    	ifFalse: [ subclassDescriptorsBuilt ]! !

!BasicTypeResolver methodsFor: 'type resolution'!

typeMappingRootDescriptor
    ^self rootDescriptor! !

!BasicTypeResolver methodsFor: 'other'!

rootDescriptor: anObject
    rootDescriptor := anObject! !

!BasicTypeResolver methodsFor: 'registering'!

register: aDescriptor abstract: abstract
    super register: aDescriptor abstract: abstract.
    abstract ifFalse: [ self concreteMembers add: aDescriptor ]! !

!BasicTypeResolver class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!IdentityTypeResolver methodsFor: 'accessing'!

describedConcreteClassFor: aRow withBuilder: builder descriptor: aDescriptor
    ^aDescriptor describedClass!

typeMappingRootDescriptor
    ^members first! !

!IdentityTypeResolver methodsFor: 'type resolution'!

classesRequiringIndependentQueriesFor: aClass
    ^Array with: aClass! !

!IdentityTypeResolver class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ExpressionGroup methodsFor: 'accessing'!

add: anExpression
    children add: anExpression.!

addAll: anExpressionCollection
    anExpressionCollection isNil ifTrue: [^self].
    children addAll: anExpressionCollection.! !

!ExpressionGroup methodsFor: 'initialize'!

initialize
    super initialize.
    children := OrderedCollection new.! !

!ExpressionGroup methodsFor: 'iterating'!

do: aBlock skipping: aSet
    "Iterate over the expression tree. Keep track of who has already been visited, so we don't get trapped in cycles or visit nodes twice."

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    children do: 	[:each | each do: aBlock skipping: aSet].
    aBlock value: self.! !

!ExpressionGroup class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ExpressionGroup class methodsFor: 'instance creation'!

with: anExpression
    ^self new add: anExpression.! !

!AttributeAccessor methodsFor: 'get/set'!

getValueFrom: anObject 
    self useDirectAccess ifTrue: [^self directGetValueFrom: anObject].
    ^anObject perform: self attributeName!

setValueIn: anObject to: aValue 
    self useDirectAccess ifTrue: [^self directSetValueIn: anObject to: aValue].
    ^anObject perform: (self attributeName , ':') asSymbol with: aValue! !

!AttributeAccessor methodsFor: 'accessing'!

attributeName
    ^attributeName!

attributeName: anObject
    attributeName := anObject!

useDirectAccess
    useDirectAccess isNil ifTrue: [useDirectAccess := true].
    ^useDirectAccess!

useDirectAccess: anObject
    useDirectAccess := anObject! !

!AttributeAccessor methodsFor: 'private'!

directGetValueFrom: anObject 
    | index |
    index := self instVarIndexIn: anObject.
    index = 0 ifTrue: [self raiseInvalidAttributeError].
    ^anObject instVarAt: index!

directSetValueIn: anObject to: aValue 
    | index |
    index := self instVarIndexIn: anObject.
    index = 0 ifTrue: [self raiseInvalidAttributeError].
    ^anObject instVarAt: index put: aValue!

instVarIndexIn: anObject 
    | soughtName |
    (lastClassUsed == anObject class and: [attributeIndex notNil]) ifTrue: [^attributeIndex].

    lastClassUsed := anObject class.
    soughtName := Dialect instVarNameFor: attributeName.
    attributeIndex := lastClassUsed allInstVarNames indexOf: soughtName.
    ^attributeIndex!

raiseInvalidAttributeError
    self error: 'Invalid attribute'! !

!AttributeAccessor class methodsFor: 'instance creation'!

newForAttributeNamed: aString 
    ^(self new)
    	attributeName: aString;
    	yourself! !

!AttributeAccessor class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ConditionalMapping methodsFor: 'testing'!

controlsTables
    self error: 'What should we do here?'!

isRelationship
    ^false! !

!ConditionalMapping methodsFor: 'accessing'!

conditionalField: aField
    conditionalField := aField.!

conditionalFieldMapping
    ^conditionalFieldMapping!

conditionalFieldMapping: aMapping
    "This is a write-only mapping for the conditional field value, which writes out the result of performing the conditional method"
    conditionalFieldMapping := aMapping!

conditionalMethod: aSymbol
    conditionalMethod := aSymbol.!

descriptor: aDescriptor
    super descriptor: aDescriptor.
    cases do: [:each | each value descriptor: aDescriptor].
    otherwiseCase descriptor: aDescriptor.
    conditionalFieldMapping isNil ifFalse: [conditionalFieldMapping descriptor: aDescriptor].!

mappedFields
    | all |
    all := OrderedCollection new.
    conditionalFieldMapping isNil 
    	ifTrue: [all add: conditionalField]
    	ifFalse: [all addAll: conditionalFieldMapping mappedFields].
    cases do: [:each |
    	all addAll: each value mappedFields].
    ^all.! !

!ConditionalMapping methodsFor: 'mapping'!

applicableMappingForObject: anObject 
    | conditionalValue |
    conditionalValue := self conditionalValueFor: anObject.
    ^cases detect: [:each | self descriptor system perform: each key with: conditionalValue]
    	ifNone: [otherwiseCase]!

applicableMappingForRow: anArray in: anElementBuilder 
    | rowValue |
    rowValue := anElementBuilder valueOfField: conditionalField in: anArray.
    cases do: 
    		[:each | 
    		(self descriptor system perform: each key with: rowValue) 
    			ifTrue: [^each value]].
    ^otherwiseCase!

conditionalValueFor: anObject 
    ^anObject perform: conditionalMethod!

mapFromObject: anObject intoRowsIn: aRowMap 
    readOnly ifTrue: [^self].
    (self applicableMappingForObject: anObject) 
    	mapFromObject: anObject
    	intoRowsIn: aRowMap.
    conditionalFieldMapping isNil ifTrue: [^self].
    conditionalFieldMapping 
    	mapFromObject: (self conditionalValueFor: anObject)
    	intoRowsIn: aRowMap!

mapObject: anObject inElementBuilder: anElementBuilder
    (self applicableMappingForRow: anElementBuilder row in: anElementBuilder)
    	mapObject: anObject
    	inElementBuilder: anElementBuilder.!

referencedIndependentObjectsFrom: anObject
    | allReferencedObjects |
    allReferencedObjects := OrderedCollection new.
    cases do: [:each | 
    	allReferencedObjects addAll: (each value referencedIndependentObjectsFrom: anObject)].
    ^allReferencedObjects.! !

!ConditionalMapping methodsFor: 'conditions'!

if: conditionSelector then: aMapping
    cases add: (Association key: conditionSelector value: aMapping).!

otherwise: aMapping
    otherwiseCase := aMapping.!

trace: aTracing context: anExpression
    "To make a join, we need to look at all of our possible cases"

    conditionalFieldMapping isNil ifFalse: [
    	conditionalFieldMapping trace: aTracing context: anExpression].
    cases do: [:each |
    	each value trace: aTracing context: anExpression].! !

!ConditionalMapping methodsFor: 'initialize/release'!

initialize
    
    super initialize.
    cases := OrderedCollection new.! !

!ConditionalMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!BooleanType methodsFor: 'converting'!

converterForStType: aClass
    (aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToBoolean].
    ^self platform nullConverter.!

impliedSmalltalkType
    ^Boolean.! !

!BooleanType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!RowMapForMementos methodsFor: 'api'!

adjustForMementos: objects
    "We may be being passed row map keys that refer to originals when they should refer to mementos. Fix.This is horribly ugly."

    1 to: objects size do: [:i | | possibleRowMapKey |
    	possibleRowMapKey := objects at: i.
    	possibleRowMapKey class == RowMapKey ifTrue: [
    		objects at: i put: (self adjustRowMapKey: possibleRowMapKey)]].
    ^objects.!

adjustRowMapKey: aRowMapKey
    | key1 key2 newRowMapKey |
    newRowMapKey := aRowMapKey copy.
    key1 := aRowMapKey key1.
    newRowMapKey key1: (correspondenceMap at: key1 ifAbsent: [key1]).
    key2 := aRowMapKey key2.
    newRowMapKey key2: (correspondenceMap at: key2 ifAbsent: [key2]).
    ^newRowMapKey.!

findOrAddRowForTable: aTable withKey: aKey 
    | mementoKey |
    mementoKey := correspondenceMap at: aKey ifAbsent: [aKey].
    ^super findOrAddRowForTable: aTable withKey: mementoKey.!

reverseAdjustRowMapKey: aRowMapKey
    | key1 key2 newRowMapKey |
    newRowMapKey := aRowMapKey copy.
    key1 := aRowMapKey key1.
    newRowMapKey key1: (correspondenceMap keyAtValue: key1).
    key2 := aRowMapKey key2.
    newRowMapKey key2: (correspondenceMap keyAtValue: key2).
    ^newRowMapKey.!

rowForTable: aTable withKey: aKey ifAbsent: aBlock 
    | correspondingObject |
    correspondingObject := aKey class == RowMapKey
    			ifTrue: [self adjustRowMapKey: aKey]
    			ifFalse: [correspondenceMap at: aKey ifAbsent: [nil]].
    ^super
    	rowForTable: aTable
    	withKey: correspondingObject
    	ifAbsent: aBlock! !

!RowMapForMementos methodsFor: 'private/mapping'!

collectionMementoFor: aCollection
    aCollection glorpIsCollection ifFalse: [^aCollection].
    ^correspondenceMap at: aCollection.!

originalObjectFor: anObject
    ^correspondenceMap at: anObject.!

reverseLookup: anObject
    anObject class == RowMapKey ifTrue: [
    	^self reverseAdjustRowMapKey: anObject].
    ^correspondenceMap keyAtValue: anObject.! !

!RowMapForMementos methodsFor: 'iterating'!

objectsAndRowsDo1: aTwoArgumentBlock
    "For a memento map, use the original objects, not the mementos"

    rowDictionary
    	do:
    		[:eachObjectToRowDictionary | 
    		eachObjectToRowDictionary
    			keysAndValuesDo:
    				[:eachKey :eachValue | 
    				aTwoArgumentBlock
    					value: (self originalObjectFor: eachKey)
    					value: eachValue]].! !

!RowMapForMementos methodsFor: 'accessing'!

correspondenceMap: anObject
    correspondenceMap := anObject! !

!RowMapForMementos class methodsFor: 'instance creation'!

withCorrespondenceMap: aDictionary
    ^self new
    	correspondenceMap: aDictionary.! !

!RowMapForMementos class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseField methodsFor: 'printing'!

asConstraintReferenceString
    ^table name, ' (', self name, ')'.!

printForConstraintNameOn: aStream maxLength: maxLength 
    | constraintName |
    constraintName := table name , '_' , name.
    constraintName size > maxLength 
    	ifTrue: [constraintName := constraintName copyFrom: 1 to: maxLength].
    aStream nextPutAll: constraintName!

printNameOn: aStream withParameters: anArray 
    aStream nextPutAll: self name!

printOn: aStream
    
    aStream nextPutAll: 'Field'.
    aStream 
    	nextPutAll: '(';
    	nextPutAll: (table isNil ifTrue: [''] ifFalse: [table name]);
    	nextPutAll: '.';
    	nextPutAll: name;
    	nextPutAll: ')'.!

printQualifiedSQLOn: aStream withParameters: aDictionary 
    aStream nextPutAll: self qualifiedName "self name"!

printSQLOn: aStream withParameters: anArray 
    aStream nextPutAll: self qualifiedName "self name"!

printUnqualifiedSQLOn: aStream withParameters: anArray 
    aStream nextPutAll: self name.! !

!DatabaseField methodsFor: 'initializing'!

initialize
    isPrimaryKey := false.
    isNullable := true.
    isUnique := false.!

postInitializeIn: aDescriptorSystem
    "Any initialization that has to be delayed until we're in the table"
    type initializeForField: self in: aDescriptorSystem.! !

!DatabaseField methodsFor: 'accessing'!

impliedSmalltalkType
    "Return the default Smalltalk type corresponding to our database type"

    ^self type impliedSmalltalkType.!

name
    "Private - Answer the value of the receiver's ''name'' instance variable."

    ^name!

name: anObject
    "Private - Set the value of the receiver's ''name'' instance variable to the argument, anObject."

    name := anObject!

position
    ^position!

position: anObject
    position := anObject!

table
    "Private - Answer the value of the receiver's ''table'' instance variable."

    ^table!

table: anObject
    "Private - Set the value of the receiver's ''table'' instance variable to the argument, anObject."

    table := anObject!

type
    ^type! !

!DatabaseField methodsFor: 'database'!

typeString
    ^type typeString! !

!DatabaseField methodsFor: 'converting'!

asGlorpExpression
    ^ParameterExpression forField: self basedOn: nil.!

asGlorpExpressionOn: anExpression
    ^ParameterExpression forField: self basedOn: anExpression.!

converterForStType: aClass
    ^self type converterForStType: (aClass isBehavior ifTrue: [aClass] ifFalse: [aClass class]).! !

!DatabaseField methodsFor: 'testing'!

isGenerated
    ^type isGenerated!

isNullable
    
    ^isNullable.!

isPrimaryKey
    "Private - Answer the value of the receiver's ''isPrimaryKey'' instance variable."

    ^isPrimaryKey!

isUnique
    ^isUnique.! !

!DatabaseField methodsFor: 'configuring'!

beNullable: aBoolean
    self isPrimaryKey ifFalse: [ isNullable := aBoolean ]!

bePrimaryKey
    isPrimaryKey := true.
    isNullable := false.
    self table isNil ifFalse: [self table addAsPrimaryKeyField: self]!

isUnique: aBoolean
    isUnique := aBoolean.!

type: aDatabaseType
    type := aDatabaseType.! !

!DatabaseField methodsFor: 'querying'!

qualifiedName
    ^table isNil 
    	ifTrue: [self name]
    	ifFalse: [self table qualifiedName, '.', self name].! !

!DatabaseField class methodsFor: 'instance creation'!

named: aString
    ^self error: 'type needed'!

named: aString type: dbType
    ^super new initialize
    	name: aString;
    	type: dbType!

new
    ^self error: 'dbType needed'! !

!DatabaseField class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!CharType methodsFor: 'SQL'!

typeString
    ^'char(', width printString, ')'! !

!CharType methodsFor: 'testing'!

isVariableWidth
    ^false.! !

!CharType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!MessageArchiver methodsFor: 'doesNotUnderstand'!

= anObject
    "Needed because VA's abtObservableWrapper implements =. Should be portable."
    ^MessageArchiver 
    	receiver: self
    	message: (Message selector: #= arguments: (Array with: anObject)).!

basicDoesNotUnderstand: aMessage 
    "Invoke this to avoid infinite recursion in the case of internal errors. We want a dialect-independent way of getting a walkback window, so we'll invoke it against a different object"


    (Array with: self) doesNotUnderstand: aMessage.!

doesNotUnderstand: aMessage 
    | sel |
    sel := aMessage selector.
    sel == #doesNotUnderstand: ifTrue: [self basicDoesNotUnderstand: aMessage].
    (sel size >= 8 and: [(sel copyFrom: 1 to: 8) = 'perform:']) 
    	ifTrue: 
    		[^self get: aMessage arguments first
    			withArguments: (aMessage arguments copyFrom: 2 to: aMessage arguments size)].
    ^MessageArchiver receiver: self message: aMessage! !

!MessageArchiver methodsFor: 'testing'!

isGlorpExpression
    ^false.! !

!MessageArchiver methodsFor: 'debugging'!

asText
    ^self basicPrintString asText.!

basicPrintString
    ^self printString.!

class
    ^MessageArchiver!

halt
    "Support this so that we can debug inside query blocks. For portability, send it to a different object so that we don't have to care how halt is implemented"

    (Array with: self) halt.!

inspect
    "Not exactly the intended semantics, but should be portable"
    (Array with: self) inspect.!

inspectorClasses
    "Answer a sequence of inspector classes that can represent the receiver in an
    inspector. The first page in the array is the one used by default in a new inspector."

    ^Array with: (Dialect smalltalkAt: 'Tools.Trippy.BasicInspector')!

inspectorExtraAttributes
    ^#()!

inspectorSize
  ^2!

printOn: aStream
    aStream nextPutAll: self printString.!

printString
    "Hard-code this for maximum dialect portability"
    ^'a MessageArchiver'.! !

!MessageArchiver methodsFor: 'private/accessing'!

privateGlorpMessage
    ^myMessage!

privateGlorpReceiver
    ^myReceiver! !

!MessageArchiver methodsFor: 'expression creation'!

asGlorpExpression
    ^self asGlorpExpressionOn: BaseExpression new!

asGlorpExpressionOn: aBaseExpression 
    | arguments |
    myReceiver == nil ifTrue: [^aBaseExpression].
    arguments := myMessage arguments collect: [:each | each asGlorpExpressionOn: aBaseExpression].
    ^(myReceiver asGlorpExpressionOn: aBaseExpression) get: myMessage selector
    	withArguments: arguments.! !

!MessageArchiver methodsFor: 'expression protocol'!

between: anObject and: anotherObject
    ^(self > anObject) & (self < anotherObject).!

get: aSymbol 
    ^MessageArchiver receiver: self
    	message: (Message selector: aSymbol arguments: #())!

get: aSymbol withArguments: anArray 
    ^MessageArchiver receiver: self
    	message: (Message selector: aSymbol arguments: anArray)! !

!MessageArchiver methodsFor: 'initialize'!

receiver: aMessageCollector message: aMessage
    myReceiver := aMessageCollector.
    myMessage := aMessage.! !

!MessageArchiver class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!MessageArchiver class methodsFor: 'instance creation'!

receiver: aMessageCollector message: aMessage
    ^self new
    	receiver: aMessageCollector
    	message: aMessage.! !

!MultipleRowMapKey methodsFor: 'accessing'!

addKey: aKey
    keys add: aKey.!

keys
    ^keys.! !

!MultipleRowMapKey methodsFor: 'printing'!

printOn: aStream
    aStream nextPutAll: 'KEY('.
    self hash printOn: aStream.
    aStream nextPutAll: '):'.
    keys printOn: aStream.! !

!MultipleRowMapKey methodsFor: 'comparing'!

= aRowMapKey
    aRowMapKey class == self class ifFalse: [^false].
    aRowMapKey keys do: [:each |
    	(keys includes: each) ifFalse: [^false]].
    ^true.!

hash
    ^keys inject: 0 into: [:sum :each |
    	sum bitXor: each identityHash].! !

!MultipleRowMapKey methodsFor: 'initialize-release'!

initialize
    keys := IdentitySet new.! !

!MultipleRowMapKey class methodsFor: 'instance creation'!

new
    "Answer a newly created and initialized instance."

    ^super new initialize!

with: key1 with: key2 with: key3
    ^self new 
    	addKey: key1;
    	addKey: key2;
    	addKey: key3;
    	yourself.! !

!RowMapKey methodsFor: 'accessing'!

key1
    ^key1!

key1: anObject
    key1 := anObject!

key2
    ^key2!

key2: anObject
    key2 := anObject! !

!RowMapKey methodsFor: 'comparing'!

= aRowMapKey
    aRowMapKey class == self class ifFalse: [^false].
    ^(key1 == aRowMapKey key1 and: [key2 == aRowMapKey key2]) or: [
    	key2 == aRowMapKey key1 and: [key1 == aRowMapKey key2]].!

hash
    ^key1 identityHash bitXor: key2 identityHash.! !

!RowMapKey class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!RelationExpression methodsFor: 'api'!

get: aSymbol withArguments: anArray
    "We treat NOT as a function, so we have to check for functions here"
    | functionExpression |
    functionExpression := self getFunction: aSymbol withArguments: anArray.
    functionExpression isNil ifFalse: [^functionExpression].
    ^anArray isEmpty 
    	ifTrue: [self error: 'Only binary relationships supported right now']
    	ifFalse: [RelationExpression named: aSymbol basedOn: self withArguments: anArray].! !

!RelationExpression methodsFor: 'accessing'!

beOuterJoin
    outerJoin := true.!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^true.!

isOuterJoin
    outerJoin isNil ifTrue: [outerJoin := false].
    ^outerJoin.!

leftChild
    ^leftChild!

leftChild: anExpression 
    leftChild := anExpression!

outerJoin
    outerJoin isNil ifTrue: [outerJoin := false].
    ^outerJoin.!

outerJoin: aBoolean
    outerJoin := aBoolean.!

relation
    ^relation.!

relation: aSymbol
    relation := aSymbol.!

rightChild
    ^rightChild!

rightChild: anExpression
    rightChild := anExpression! !

!RelationExpression methodsFor: 'As yet unclassified'!

canUseBinding
    "Return true if we can use binding for our right child's value"
    ^self expectsCollectionArgument not.!

expectsCollectionArgument
    ^self relationsWithCollectionArguments includes: relation.!

printForANSIJoinTo: aTableCollection on: aCommand
    "Print ourselves as table JOIN otherTable USING (criteria). Return the table we joined"
    | table |
    self outerJoin 
    	ifTrue: [aCommand nextPutAll: ' LEFT OUTER JOIN ']
    	ifFalse: [aCommand nextPutAll: ' INNER JOIN '].
    table := self tablesForANSIJoin detect: [:each | (aTableCollection includes: each) not].
    aCommand nextPutAll: table sqlTableName.
    aCommand nextPutAll: ' ON '.
    self printSQLOn: aCommand withParameters: aCommand parameters.
    ^table.!

relationsWithCollectionArguments
    ^#(#IN).!

tablesForANSIJoin
    "Which tables will we join. Assumes this is a single-level join"
    ^self inject: Set new into: [:sum :each |
    	each tableForANSIJoin isNil ifFalse: [sum add: each tableForANSIJoin].
    	sum].!

useBindingFor: aValue to: aType in: aCommand
    "Return true if we can use binding for our right child's value, in the context of this command"
    aCommand useBinding ifFalse: [^false].
    self expectsCollectionArgument ifTrue: [^false].
    ^aCommand canBind: aValue to: aType.! !

!RelationExpression methodsFor: 'private/initializing'!

named: aSymbol basedOn: anExpression withArguments: anArray
    | base right |
    outerJoin := false.
    relation := self operationFor: aSymbol.
    leftChild := anExpression.
    "The only time we don't expect anExpression to have a base is if it's a constant, in which case the other side should be a variable expression and thus have a base."
    base := anExpression canHaveBase ifTrue: [anExpression ultimateBaseExpression] ifFalse: [anArray first ultimateBaseExpression].
    right := anArray first.
    rightChild := (right isGlorpExpression and: [right canHaveBase and: [right ultimateBaseExpression == base]])
    	ifTrue: [right]
    	ifFalse: [right asGlorpExpressionOn: base].!

operationFor: aSymbol
    "Simple translation of operators"

    aSymbol == #AND: ifTrue: [^#AND].
    aSymbol == #& ifTrue: [^#AND].
    aSymbol == #OR: ifTrue: [^#OR].
    aSymbol == #| ifTrue: [^#OR].
    aSymbol == #~= ifTrue: [^#<>].
     aSymbol == #like: ifTrue: [^#LIKE].
     aSymbol == #ilike: ifTrue: [^#ILIKE].		"Case-insensitive variant of LIKE. Only supported on PostgreSQL at the moment"
     aSymbol == #in: ifTrue: [^#IN].
    ^aSymbol.! !

!RelationExpression methodsFor: 'navigating'!

ultimateBaseExpression
    ^leftChild canHaveBase ifTrue: [leftChild ultimateBaseExpression] ifFalse: [rightChild ultimateBaseExpression].! !

!RelationExpression methodsFor: 'converting'!

asIndependentJoins
    | |
    "If this is an ANDed clause, referring to two different tables split it into independent joins"
    relation == #AND ifFalse: [^Array with: self].
"	leftChild leftTableForANSIJoin == rightChild leftTableForANSIJoin ifTrue: [^Array with: self]."
    ^(Array with: leftChild with: rightChild) inject: OrderedCollection new into: [:sum :each |
    	sum addAll: each asIndependentJoins. sum].! !

!RelationExpression methodsFor: 'printing'!

printOnlySelfOn: aStream
    aStream nextPutAll: relation.!

printTreeOn: aStream 
    aStream
    	print: leftChild;
    	space;
    	nextPutAll: relation;
    	space;
    	print: rightChild! !

!RelationExpression methodsFor: 'printing SQL'!

printBasicSQLOn: aStream withParameters: aDictionary
    aStream nextPut: $(.
    leftChild
    	printSQLOn: aStream
    	withParameters: aDictionary.
    self
    	printComparisonTo: rightChild
    	withParameters: aDictionary
    	on: aStream.
    self printOracleOuterJoinOn: aStream.
    aStream nextPut: $).!

printComparisonTo: value withParameters: aDictionary on: aStream
    "Horribly convoluted logic to handle the cases where the value might be a constant, an expression that results in a value (constant or parameter) or a regular expression, with the caveat that any value that turns out to be null has to be printed with IS NULL rather than = NULL."

    | translated |
    translated := self convertValueOf: value in: aDictionary.
    translated isGlorpExpression
    	ifTrue:
    		[
    		translated isEmptyExpression ifFalse: [
    			self printRelationOn: aStream.
    			translated
    				printSQLOn: aStream
    				withParameters: aDictionary]]
    	ifFalse:
    		[self
    			printSimpleValueComparisonTo: translated
    			on: aStream].!

printMicrosoftOuterJoinOn: aCommand
    self isOuterJoin ifFalse: [^self].
    aCommand platform useMicrosoftOuterJoins ifTrue: [
    	aCommand nextPutAll: '*'].!

printOracleOuterJoinOn: aCommand
    self isOuterJoin ifFalse: [^self].
    aCommand platform useOracleOuterJoins ifTrue: [
    	aCommand nextPutAll: ' (+) '].!

printRelationOn: aStream
    aStream space.
    self printMicrosoftOuterJoinOn: aStream.
    aStream 
    	nextPutAll: self relation;
    	space.!

printSimpleValueComparisonTo: value on: aStream
    value isNil
    	ifTrue: [self printWithNullOn: aStream]
    	ifFalse:
    		[self printRelationOn: aStream.
    		self printValue: value on: aStream].!

printSQLOn: aStream withParameters: aDictionary
    self leftChild hasImpliedClauses
    	ifTrue:
    		[| impliedClauses |
    		impliedClauses := self leftChild allRelationsFor: self.
    		impliedClauses outerJoin: self outerJoin.
    		impliedClauses
    			printSQLOn: aStream
    			withParameters: aDictionary]
    	ifFalse:
    		[self
    			printBasicSQLOn: aStream
    			withParameters: aDictionary].!

printValue: value on: aCommand
    | type |
    type := self leftChild field type.
    (self useBindingFor: value to: type in: aCommand) ifTrue: [^aCommand nextPutAll: '?'].
    self expectsCollectionArgument
    	ifTrue:
    		[type
    			printCollection: value
    			on: aCommand]
    	ifFalse:
    		[type
    			print: value
    			on: aCommand].!

printWithNullOn: aStream
    aStream nextPutAll: ' IS '.
    self relation = #<> ifTrue: [
    	aStream nextPutAll: 'NOT '].
    aStream nextPutAll: 'NULL'.! !

!RelationExpression methodsFor: 'iterating'!

convertValueOf: anObject in: aDictionary
    | translated convertedValue |

    translated := anObject isGlorpExpression 
    	ifTrue: [anObject valueIn: aDictionary]
    	ifFalse: [anObject].
    translated isGlorpExpression ifTrue: [^translated].
    convertedValue := self expectsCollectionArgument 
    	ifTrue: [translated collect: [:each | self leftChild convertedDbValueOf: each]]
    	ifFalse: [self leftChild convertedDbValueOf: translated].
    ^convertedValue.!

do: aBlock skipping: aSet
    | clauses |
    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    leftChild hasImpliedClauses
    	ifTrue:
    		[clauses := leftChild allRelationsFor: self.
    		clauses do: [:each | each do: aBlock skipping: aSet]]
    	ifFalse:
    		[leftChild do: aBlock skipping: aSet.
    		rightChild do: aBlock skipping: aSet.
    		aBlock value: self.].! !

!RelationExpression methodsFor: 'preparing'!

additionalExpressions
    ^#().!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    | left right |
    left := leftChild asExpressionJoiningSource: source toTarget: target.
    right := rightChild asExpressionJoiningSource: source toTarget: target.
    ^self class new 
    	relation: relation;
    	leftChild: left;
    	rightChild: right.!

bindingIn: aCommand
    ^self convertValueOf: rightChild in: aCommand parameters.!

hasBindableExpressionsIn: aCommand
    "Return true if our right-child can be used for binding. We need to do this at this level because the expressions themselves don't know what type they'll be matched against"

    | translated |
    rightChild canBind ifFalse: [^false].
    translated := self convertValueOf: rightChild in: aCommand parameters.
    ^self useBindingFor: translated to: leftChild field type in: aCommand.!

rebuildOn: aBaseExpression 
    | expression |
    expression := (leftChild rebuildOn: aBaseExpression) 
    	get: relation 
    	withArguments: (Array with: (rightChild rebuildOn: aBaseExpression)).
    self isOuterJoin ifTrue: [expression beOuterJoin].
    ^expression.! !

!RelationExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!RelationExpression class methodsFor: 'instance creation'!

named: aSymbol basedOn: anExpression withArguments: anArray
    ^self new
    	named: aSymbol
    	basedOn: anExpression
    	withArguments: anArray.! !

!CollectionExpression methodsFor: 'printing SQL'!

printSQLOn: aStream withParameters: aDictionary 
    "Don't print the left child or ourselves, just the expression that is the right side.
e.g. aPerson addresses anySatisfy: [:each | each city='Ottawa'] prints as
where (address.city = 'Ottawa')
The relation 'aPerson addresses' will ensure that the join gets printed"
    rightChild printSQLOn: aStream withParameters: aDictionary.! !

!CollectionExpression methodsFor: 'private/initializing'!

named: aSymbol basedOn: anExpression withArguments: anArray
    "Create ourselves based on anExpression. Our argument is expected to be a block operating on the elements of the receiver, i.e. the leftChild. e.g. leftChild anySatisfy: [...].
    Turn the block into an expression, using a temporary base. Otherwise subclauses in the block will end up trying to use the ultimate base expression. This is ugly, but I can't think of a good alternative"

    | |
    relation := aSymbol.
    leftChild := anExpression.
    myLocalExpression := anArray first asGlorpExpressionOn: self myLocalBase.
    rightChild := myLocalExpression rebuildOn: leftChild.! !

!CollectionExpression methodsFor: 'accessing'!

myLocalBase
    myLocalBase isNil ifTrue: [myLocalBase := BaseExpression new].
    ^myLocalBase.!

myLocalBase: anExpression
    myLocalBase := anExpression.! !

!CollectionExpression methodsFor: 'preparing'!

rebuildOn: aBaseExpression 
    | expression |
    expression := (leftChild rebuildOn: aBaseExpression) 
    	get: relation 
    	withArguments: (Array with: myLocalExpression).
    self isOuterJoin ifTrue: [expression beOuterJoin].
    ^expression.! !

!CollectionExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FilteredTypeResolver methodsFor: 'registering'!

register: aDescriptor keyedBy: aKey field: aField
    self register: aDescriptor abstract: false.
    aDescriptor typeMapping: (FilteredTypeMapping to: aField keyedBy: aKey).! !

!FilteredTypeResolver methodsFor: 'type resolving'!

describedConcreteClassFor: row withBuilder: builder descriptor: aDescriptor
    ^aDescriptor typeMapping describedConcreteClassFor: row withBuilder: builder!

fieldsForSelectStatement
    "Return fields that are needed in a select statement - i.e. return all inherited fields that are part of the tables we are already selecting for this object, but not in the main descriptor"
    | fields rootFields |
    fields := OrderedCollection new.
    rootFields := self rootDescriptor mappedFields asSet.
    self concreteMembers do: [:each |
    	each == self rootDescriptor ifFalse: [
    		each mappedFields do: [:eachSubField |
    			(rootFields includes: eachSubField) ifFalse: [
    				fields add: eachSubField]]]].
    ^fields.! !

!FilteredTypeResolver methodsFor: 'accessing'!

classesRequiringIndependentQueriesFor: aClass
    ^Array with: aClass! !

!FilteredTypeResolver class methodsFor: 'instance creation'!

forRootClass: aClass
    ^self new
    	rootClass: aClass;
    	yourself.! !

!FilteredTypeResolver class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ObjectExpression methodsFor: 'fields'!

aliasedTableFor: aDatabaseTable 
    tableAliases isNil ifTrue: [^aDatabaseTable].
    aDatabaseTable isAliased ifTrue: [^aDatabaseTable].
    ^tableAliases at: aDatabaseTable.!

aliasedTableFor: aDatabaseTable  ifAbsent: aBlock
    tableAliases isNil ifTrue: [^aBlock value].
    aDatabaseTable isAliased ifTrue: [^aDatabaseTable].
    ^tableAliases at: aDatabaseTable ifAbsent: [aBlock value].!

aliasTable: aDatabaseTable to: aString 
    | newTable |
    newTable := aDatabaseTable copy.
    newTable schema: ''.
    newTable name: aString.
    newTable parent: aDatabaseTable.
    self tableAliases at: aDatabaseTable put: newTable!

controlsTables
    self subclassResponsibility.!

newFieldExpressionFor: aField
    ^FieldExpression forField: aField basedOn: self!

translateField: aDatabaseField 
    | newTable |
    newTable := self aliasedTableFor: aDatabaseField table.
    newTable == aDatabaseField table ifTrue: [^aDatabaseField].
    ^self fieldAliases 
    	at: aDatabaseField
    	ifAbsentPut: 
    		[| newField |
    		newField := aDatabaseField copy.
    		newField table: newTable]!

translateFields: anOrderedCollection 
    ^anOrderedCollection collect: [:each | self translateField: each]! !

!ObjectExpression methodsFor: 'api'!

get: aSymbol 
    "Return the mapping expression corresponding to the named attribute"

    | reallyASymbol |
    reallyASymbol := aSymbol asSymbol.
    ^mappingExpressions at: reallyASymbol
    	ifAbsentPut: [MappingExpression named: reallyASymbol basedOn: self]!

get: aSymbol withArguments: anArray
    "Return the mapping expression corresponding to the named attribute"
    (#(#getTable: #getField: #parameter:) includes: aSymbol) ifTrue: [
    	^self perform: aSymbol withArguments: anArray].

    ^anArray isEmpty 
    	ifTrue: [self get: aSymbol]
    	ifFalse: [RelationExpression named: aSymbol basedOn: self withArguments: anArray].!

getField: aField
    | realField |
    realField := aField isString ifTrue: [self table fieldNamed: aField] ifFalse: [aField].
    "This might be an expression, most notably a constant expression, in which case it either contains a string or a field"
    realField isGlorpExpression ifTrue: [
    	realField value isString ifTrue: [realField := self table fieldNamed: realField value] 
    	ifFalse: [^realField]].

    ^mappingExpressions at: realField ifAbsentPut: [self newFieldExpressionFor: realField].!

getTable: aTable
    "This can take a string, a constantExpression containing a string, or a table object"

    | realTable |
    realTable := aTable isString
    	ifTrue: [self system tableNamed: aTable]
    	ifFalse: [aTable].	"This might be an expression, most notably a constant expression, in which case it either contains a string or a field"
    realTable isGlorpExpression
    	ifTrue:
    		[realTable value isString
    			ifTrue: [realTable := self system tableNamed: realTable value]
    			ifFalse: [realTable := realTable value]].
    ^mappingExpressions
    	at: realTable
    	ifAbsentPut: [TableExpression forTable: realTable basedOn: self].! !

!ObjectExpression methodsFor: 'accessing'!

fieldAliases
    fieldAliases isNil ifTrue: [fieldAliases := IdentityDictionary new].
    ^fieldAliases.!

requiresDistinct
    ^requiresDistinct!

requiresDistinct: aBoolean 
    requiresDistinct := aBoolean!

system
    self subclassResponsibility.!

tableAliases
    tableAliases isNil ifTrue: [
    	tableAliases := IdentityDictionary new: 3].
    ^tableAliases! !

!ObjectExpression methodsFor: 'preparing'!

assignTableAliasesStartingAt: anInteger 
    | tableNumber |
    self controlsTables ifFalse: [^anInteger].
    tableNumber := anInteger.
    self tables do: [:each |
    	self aliasTable: each to: 't', tableNumber printString.
    	tableNumber := tableNumber + 1].
    ^tableNumber! !

!ObjectExpression methodsFor: 'private/accessing'!

removeMappingExpression: anExpression
    "Private. Normally you would never do this, but in the case of an anySatisfy: or allSatisfy: we want to have each of them as distinct joins, so we will remove the entry from the mappingExpression of the base, making sure that relationship will not be used for anything else. Since any/allSatisfy: is the only valid use of a collection relationship, we don't have to worry about whether it was used for something else earlier."

    mappingExpressions removeKey: anExpression name.! !

!ObjectExpression methodsFor: 'printing'!

printTableAliasesOn: aStream 
    self hasTableAliases 
    	ifTrue: 
    		[aStream nextPutAll: ' '.
    		tableAliases keysAndValuesDo: [:eachKey :eachValue | 
    			aStream nextPutAll: eachKey name, '->', eachValue name , ' ']]! !

!ObjectExpression methodsFor: 'tests'!

hasTableAliases
    ^tableAliases notNil! !

!ObjectExpression methodsFor: 'initialize'!

initialize
    super initialize.
    mappingExpressions := IdentityDictionary new.
    requiresDistinct := false.! !

!ObjectExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TableExpression methodsFor: 'accessing'!

base
    ^base.!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^true.!

printsTable
    ^true.!

table
    ^table.!

ultimateBaseExpression
    ^base ultimateBaseExpression.! !

!TableExpression methodsFor: 'preparing'!

aliasedTableFor: aDatabaseTable 
    ^self controlsTables 
    	ifTrue: [super aliasedTableFor: aDatabaseTable]
    	ifFalse: [base aliasedTableFor: aDatabaseTable]!

aliasedTableFor: aDatabaseTable ifAbsent: aBlock
    ^self controlsTables 
    	ifTrue: [super aliasedTableFor: aDatabaseTable ifAbsent: aBlock]
    	ifFalse: [base aliasedTableFor: aDatabaseTable ifAbsent: aBlock]!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    ^target getTable: table.!

controlsTables
    "We can end up with a table expression built on top of a base that has the same table. If so, we don't count as controlling that table"

    base isNil ifTrue: [^true].
    base hasDescriptor ifFalse: [^true].
    ^(base descriptor tables includes: table) not.!

tables
    ^Array with: table.!

tablesToPrint
    self controlsTables ifFalse: [^#()].
    ^Array with: (self aliasedTableFor: table).! !

!TableExpression methodsFor: 'printing'!

printOnlySelfOn: aStream
    table printSQLOn: aStream withParameters: #().
    self printTableAliasesOn: aStream.!

printTreeOn: aStream 
    base printOn: aStream.
    aStream nextPut: $..
    table printSQLOn: aStream withParameters: #()! !

!TableExpression methodsFor: 'initialize/release'!

table: aDatabaseTable base: aBaseExpression
    table := aDatabaseTable.
    base := aBaseExpression.! !

!TableExpression methodsFor: 'As yet unclassified'!

rebuildOn: aBaseExpression
    ^aBaseExpression getTable: table.! !

!TableExpression methodsFor: 'iterating'!

do: aBlock skipping: aSet
    "Iterate over the expression tree"

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    base do: aBlock skipping: aSet.
    aBlock value: self.! !

!TableExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TableExpression class methodsFor: 'instance creation'!

forTable: aDatabaseTable basedOn: aBaseExpression
    ^self new table: aDatabaseTable base: aBaseExpression; yourself! !

!MappingExpression methodsFor: 'As yet unclassified'!

allRelationsFor: rootExpression
    ^self mapping allRelationsFor: rootExpression.!

asOuterJoin
    outerJoin := true.!

convertedDbValueOf: anObject
    ^self mapping convertedDbValueOf: anObject.!

convertedStValueOf: anObject
    ^self mapping convertedStValueOf: anObject.!

valueInBuilder: anElementBuilder
    ^self mapping valueIn: anElementBuilder withFieldContextFrom: self base.! !

!MappingExpression methodsFor: 'fields'!

aliasedTableFor: aDatabaseTable 
    ^self controlsTables 
    	ifTrue: [super aliasedTableFor: aDatabaseTable]
    	ifFalse: [base aliasedTableFor: aDatabaseTable]!

aliasedTableFor: aDatabaseTable ifAbsent: aBlock
    ^self controlsTables 
    	ifTrue: [super aliasedTableFor: aDatabaseTable ifAbsent: aBlock]
    	ifFalse: [base aliasedTableFor: aDatabaseTable ifAbsent: aBlock]!

controlsTables
    | mapping |
    mapping := self mapping.
    mapping isNil ifTrue: [^false].
    ^mapping controlsTables! !

!MappingExpression methodsFor: 'accessing'!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^true.!

descriptor
    ^self system descriptorFor: self mapping referenceClass.!

field
    | mapping |
    mapping := self mapping.
    mapping isNil ifTrue: [self error: '"', name, '" is not a mapped property name in ', base descriptor describedClass name].
    mapping isRelationship ifTrue: [self error: '"',name, '" is not an attribute that resolves to a field in the mapped tables for ', base descriptor describedClass name].
    ^base translateField: mapping field.!

hasDescriptor
    "Does the object that we describe have its own descriptor"
    ^self mapping isRelationship!

mappedFields
    | mapping |
    mapping := self mapping.
    mapping isNil ifTrue: [self error: '"', name, '" is not a mapped property name in ', base descriptor describedClass name].
    mapping isRelationship ifTrue: [self error: '"',name, '" is not an attribute that resolves to a field in the mapped tables for ', base descriptor describedClass name].
    ^self mapping mappedFields collect: [:each | base translateField: each].!

multipleTableExpressions
    ^self mapping multipleTableExpressionsFor: self.!

name
    ^name.!

requiresDistinct: aBoolean
    super requiresDistinct: aBoolean.
    base requiresDistinct: aBoolean.!

sourceDescriptor
    ^base descriptor.!

system
    ^base system.!

table
    self hasDescriptor ifTrue: [self error: 'trying to get a single table for a non-direct mapping'].
    ^self field table.!

tables
    | set |
    self controlsTables ifFalse: [^#()].
    set := self descriptor tables asSet.
    ^set.! !

!MappingExpression methodsFor: 'printing'!

printOnlySelfOn: aStream
    aStream nextPutAll: name.
    self printTableAliasesOn: aStream.!

printTreeOn: aStream 
    aStream
    	print: base;
    	nextPut: $.;
    	nextPutAll: name! !

!MappingExpression methodsFor: 'testing'!

canBeUsedForRetrieve
    "Return true if this is a valid argument for a retrieve: clause"
    ^self mapping canBeUsedForRetrieve.!

canKnit
    "Return true if, when building objects, we can knit the object corresponding to this expression to a related object. Roughly speaking, is this a mapping expression"
    ^true.!

hasImpliedClauses
    ^self mapping notNil and: [self mapping hasImpliedClauses].! !

!MappingExpression methodsFor: 'preparing'!

additionalExpressions
    | exp |
    exp := self mapping joinExpressionFor: self.
    outerJoin ifTrue: [exp beOuterJoin].
    ^self multipleTableExpressions, (exp isNil ifTrue: [#()] ifFalse: [Array with: exp]).!

allRelationsFor: rootExpression do: aBlock andBetweenDo: anotherBlock
    "We might have multiple clauses to print, depending on our mapping"
    self mapping 
    	allRelationsFor: rootExpression
    	do: aBlock
    	andBetweenDo: anotherBlock.!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    | newBase |
    newBase := base asExpressionJoiningSource: source toTarget: target.
    ^self class named: name basedOn: newBase.!

fieldsForSelectStatement
    
    ^self mapping fieldsForSelectStatement.!

rebuildOn: aBaseExpression 
    | expression |
    expression := (base rebuildOn: aBaseExpression) get: name.
    outerJoin ifTrue: [expression asOuterJoin].
    ^expression.!

tablesToPrint
    self hasDescriptor ifFalse: [^#()].
    ^self tables collect: [:each |
    	self aliasedTableFor: each].!

translateField: aDatabaseField
    | translatedField |
    translatedField := (self mapping translateFields: (Array with: aDatabaseField)) first.
    ^super translateField: (translatedField isNil ifTrue: [aDatabaseField] ifFalse: [translatedField]).!

translateFields: anOrderedCollection 
    "Ugh. Unify these mechnisms"
    ^super translateFields: (self mapping translateFields: anOrderedCollection).!

validate
    self mapping isNil ifTrue: [self error: 'no mapping for ', self printString].! !

!MappingExpression methodsFor: 'iterating'!

do: aBlock skipping: aSet
    "Iterate over the expression tree"

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    base do: aBlock skipping: aSet.
    aBlock value: self.! !

!MappingExpression methodsFor: 'api'!

base
    ^base.!

get: aSymbol withArguments: anArray 
    | functionExpression |
    aSymbol == #anySatisfy: 
    	ifTrue: [^self anySatisfyExpressionWithArguments: anArray].
    aSymbol == #asOuterJoin
    	ifTrue: [^self asOuterJoin].
    functionExpression := self getFunction: aSymbol withArguments: anArray.
    functionExpression isNil ifFalse: [^functionExpression].
    ^super get: aSymbol withArguments: anArray! !

!MappingExpression methodsFor: 'private/initialization'!

named: aSymbol basedOn: anExpression
    name := aSymbol.
    base := anExpression.
    outerJoin := false.! !

!MappingExpression methodsFor: 'navigating'!

ultimateBaseExpression
    ^base ultimateBaseExpression.! !

!MappingExpression methodsFor: 'internal'!

anySatisfyExpressionWithArguments: anArray 
    | newExpression |
    self base requiresDistinct: true.
    newExpression := CollectionExpression 
    	named: #anySatisfy:
    	basedOn: self
    	withArguments: anArray.
    self base removeMappingExpression: self.
    ^newExpression.!

mapping
    | descriptor |
    descriptor := self sourceDescriptor.
    descriptor isNil ifTrue: [^nil].
    ^descriptor mappingForAttributeNamed: name.! !

!MappingExpression methodsFor: 'printing SQL'!

printSQLOn: aStream withParameters: aDictionary 
    self field printSQLOn: aStream withParameters: aDictionary.! !

!MappingExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!MappingExpression class methodsFor: 'instance creation'!

named: aSymbol basedOn: anExpression
    ^self new
    	named: aSymbol
    	basedOn: anExpression.! !

!DescriptorSystem methodsFor: 'api'!

databaseSequenceNamed: aString
    ^sequences at: aString asUppercase ifAbsentPut: [platform newDatabaseSequenceNamed: aString].!

databaseSequenceNamed: aString ifAbsentPut: aBlock
    ^sequences at: aString asUppercase ifAbsentPut: aBlock.!

descriptorFor: aClassOrObject 
    | theClass |
    aClassOrObject == Proxy ifTrue: [self error: 'Cannot find descriptor for the class Proxy. Pass in the instance'].
    theClass := aClassOrObject isBehavior 
    			ifTrue: [aClassOrObject]
    			ifFalse: [aClassOrObject class == Proxy 
    						ifTrue: [aClassOrObject getValue class]
    						ifFalse: [aClassOrObject class]].

    (self allClasses includes: theClass) ifFalse: [^nil].
    ^descriptors
    	at: theClass
    	ifAbsentPut: [self newDescriptorFor: theClass]!

existingTableNamed: aString
    ^tables at: aString ifAbsent: [self error: 'missing table'].!

flushAllClasses
    allClasses := nil!

hasDescriptorFor: aClassOrObject 
    ^(self descriptorFor: aClassOrObject) notNil.!

tableNamed: aString
    ^tables at: aString asString ifAbsent: [
    	| newTable|
    	newTable := DatabaseTable new.
    	newTable name: aString.
    	tables at: aString put: newTable.
    	self initializeTable: newTable.
    	newTable].!

typeResolverFor: aClassOrObject 
    | theClass |
    aClassOrObject == Proxy ifTrue: [self error: 'Cannot find type resolver for the class Proxy. Pass in the instance'].
    theClass := aClassOrObject isBehavior 
    			ifTrue: [aClassOrObject]
    			ifFalse: [aClassOrObject class == Proxy ifTrue: [aClassOrObject getValue class] ifFalse: [aClassOrObject class]].
    ^typeResolvers at: theClass ifAbsentPut: [self newTypeResolverFor: theClass]! !

!DescriptorSystem methodsFor: 'accessing'!

allClasses
    allClasses isNil ifTrue: [allClasses := self constructAllClasses].
    ^allClasses!

allDescriptors
    ^self allClasses collect: [:each | 
    	self descriptorFor: each].!

allSequences
    sequences isEmpty ifFalse: [^sequences].
    self allTables do: [:each | 
    	each fields do: [:eachField |
    		eachField type hasSequence ifTrue: [
    			sequences at: eachField type sequence name put: eachField type sequence]]].
    ^sequences.!

allTableNames
    self subclassResponsibility.!

allTables
    ^self allTableNames collect: [:each | 
    	self tableNamed: each asString].!

cachePolicy
    "Return the default cache policy that will be used for descriptors that don't specify their own policy"
    cachePolicy isNil ifTrue: [cachePolicy := CachePolicy default].
    ^cachePolicy.!

cachePolicy: aCachePolicy
    cachePolicy := aCachePolicy.!

constructAllClasses
    ^IdentitySet new!

defaultTracing
    ^Tracing new!

platform
    ^platform!

platform: dbPlatform
    platform := dbPlatform!

session
    ^session!

session: anObject
    session := anObject!

useDirectAccessForMapping
    ^useDirectAccessForMapping!

useDirectAccessForMapping: anObject
    useDirectAccessForMapping := anObject! !

!DescriptorSystem methodsFor: 'initialization'!

setUpDefaults
    "For systems that are configurable, set them up for testing configuration"! !

!DescriptorSystem methodsFor: 'private'!

initialize
    descriptors := Dictionary new.
    tables := Dictionary new.
    typeResolvers := Dictionary new.
    sequences := Dictionary new.
    useDirectAccessForMapping := true!

initializeDescriptor: aDescriptor 
    | selector |
    selector := ('descriptorFor' , aDescriptor describedClass name , ':') asSymbol.
    (self respondsTo: selector) 
    	ifTrue: [self perform: selector with: aDescriptor]
    	ifFalse: [aDescriptor describedClass
    							glorpSetupDescriptor: aDescriptor
    							forSystem: self]!

initializeTable: newTable
    self perform: ('tableFor' , newTable name , ':') asSymbol with: newTable.
    newTable postInitializeIn: self.!

newDescriptorFor: aClass
    | newDescriptor |
    (self allClasses includes: aClass) ifFalse: [^nil].
    newDescriptor := Descriptor new.
    newDescriptor system: self.
    newDescriptor describedClass: aClass.
    self initializeDescriptor: newDescriptor.
    ^newDescriptor.!

newTypeResolverFor: aClass 
    | selector |
    (self allClasses includes: aClass) ifFalse: [^nil].
    selector := ('typeResolverFor' , aClass name) asSymbol.
    ^(self respondsTo: selector) 
    	ifTrue: [self perform: selector]
    	ifFalse: [aClass glorpTypeResolver]! !

!DescriptorSystem class methodsFor: 'instance creation'!

forPlatform: dbPlatform
    ^super new initialize;
    	platform: dbPlatform!

new
    ^super new initialize.! !

!DescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DynamicDescriptorSystem methodsFor: 'accessing'!

allClasses
    ^descriptors keys!

allTableNames
    ^tables keys! !

!DynamicDescriptorSystem methodsFor: 'private'!

privateDescriptorAt: aClass put: aDescriptor
    "Normally you don't want to be setting tables explicitly, as it may defeat the identity management but it's here if needed"
    descriptors at: aClass put: aDescriptor.!

privateTableAt: aString put: aTable
    "Normally you don't want to be setting tables explicitly, as it may defeat the identity management but it's here if needed"
    tables at: aString put: aTable.! !

!DynamicDescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!HorizontalTypeResolver methodsFor: 'accessing'!

classesRequiringIndependentQueriesFor: aClass
    ^self allDescribedConcreteClasses select: [ :each | each includesBehavior: aClass ]!

describedConcreteClassFor: row withBuilder: builder descriptor: aDescriptor
    ^aDescriptor describedClass! !

!HorizontalTypeResolver methodsFor: 'testing'!

isTypeMappingRoot: aDescriptor
    ^aDescriptor == rootDescriptor! !

!HorizontalTypeResolver class methodsFor: 'instance creation'!

forRootClass: aClass
    ^self new
    	rootClass: aClass;
    	yourself.! !

!HorizontalTypeResolver class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AbstractIntegerType methodsFor: 'converting'!

converterForStType: aClass
    (aClass includesBehavior: Boolean) ifTrue: [^self platform converterNamed: #booleanToInteger].
    ^self platform converterNamed: #numberToInteger.!

impliedSmalltalkType
    ^Integer.! !

!AbstractIntegerType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!IntegerDatabaseType methodsFor: 'SQL'!

typeString
    ^'integer'! !

!IntegerDatabaseType class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!SerialType methodsFor: 'SQL'!

postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession
    ^sequence postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession.!

preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession
    ^sequence preWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession.! !

!SerialType methodsFor: 'initialize'!

initialize
    super initialize.
    generated := true.!

initializeForField: aDatabaseField in: aDescriptorSystem
    sequence isNil ifFalse: [^self].
    sequence := aDescriptorSystem databaseSequenceNamed: (aDatabaseField table name), '_', (aDatabaseField name), '_SEQ'.! !

!SerialType methodsFor: 'accessing'!

hasParameters
    ^true.!

hasSequence
    ^true.!

isGenerated
    "answer if we should autogenerate a value for this type"

    ^generated!

sequence
    ^sequence.!

sequence: aDatabaseSequence
    sequence := aDatabaseSequence.! !

!SerialType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!SmallintDatabaseType methodsFor: 'SQL'!

typeString
    ^'smallint'! !

!SmallintDatabaseType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseAccessor methodsFor: 'accessing'!

numberOfPreparedStatements
    ^0! !

!DatabaseAccessor methodsFor: 'executing'!

createSequence: aDatabaseSequence ifError: aBlock 
    self 
    	doCommand: [self executeSQLString: aDatabaseSequence creationString]
    	ifError: aBlock!

createTable: aGLORBDatabaseTable ifError: aBlock 
    "This method should be used to create a database table from aTable"

    self 
    	doCommand: [self executeSQLString: (self platform createTableStatementStringFor: aGLORBDatabaseTable)]
    	ifError: aBlock!

createTableFKConstraints: aGLORBDatabaseTable ifError: aBlock 
    "This method should be used to define foreign key constraints for a database table from aTable"

    self doCommand: 
    		[(self platform 
    			createTableFKContraintsStatementStringsFor: aGLORBDatabaseTable) 
    				do: [:ea | self executeSQLString: ea]]
    	ifError: aBlock!

doCommand: aBlock
    ^self doCommand: aBlock ifError: [:ex | self halt].!

doCommand: aBlock ifError: errorBlock
    ^aBlock on: Exception do: errorBlock.!

dropConstraint: aConstraint 
    self doCommand: [self executeSQLString: aConstraint dropString]
    	ifError: [:ex | Transcript show: (ex messageText ifNil: [ex printString])]!

dropSequence: aSequence ifAbsent: aBlock 
    self doCommand: [self executeSQLString: 'DROP SEQUENCE ' , aSequence name]
    	ifError: aBlock!

dropSequences: anArray 
    anArray do: [:each | self dropSequence: each ifAbsent: [ :ex | Transcript show: (ex messageText ifNil: [ex printString])]]!

dropTable: aTable ifAbsent: aBlock 
    self doCommand: [aTable dropFromAccessor: self]
    	ifError: aBlock!

dropTableNamed: aString 
    self executeSQLString: 'DROP TABLE ' , aString!

dropTableNamed: aString ifAbsent: aBlock 
    self doCommand: [self executeSQLString: 'DROP TABLE ' , aString]
    	ifError: aBlock!

dropTables: anArray 
"PostgreSQL drops foreign key constraints implicitly."
    anArray do: [:each | each dropForeignKeyConstraintsFromAccessor: self].
    anArray do: [:each | self dropTable: each ifAbsent: [ :ex | Transcript show: (ex messageText ifNil: [ex printString])]].!

executeCommand: command 
    ^command useBinding 
    	ifTrue: 
    		[self executeSQLString: command sqlString withBindings: command bindings]
    	ifFalse: [self executeSQLString: command sqlString]!

executeCommandReusingPreparedStatements: aCommand
    "Not all platforms support this, so by default, just execute regularly. Subclasses may override"
    self executeCommand: aCommand.!

executeSQLString: aString
    self subclassResponsibility.!

executeSQLString: aTemplateString withBindings: aBindingArray
    self subclassResponsibility.!

externalDatabaseErrorSignal
    self subclassResponsibility.! !

!DatabaseAccessor methodsFor: 'accessing'!

connection
    ^connection!

connectionClass
    ^(self connectionClassForLogin: currentLogin)!

currentLogin
    ^currentLogin!

currentLogin: aLogin 
    currentLogin := aLogin!

platform
    ^currentLogin database.! !

!DatabaseAccessor methodsFor: 'logging'!

log: aStringOrBlock 
    self logging 
    	ifTrue: 
    		[Transcript
    			show: (aStringOrBlock isString ifTrue: [aStringOrBlock] ifFalse: [aStringOrBlock value]);
    			nl]!

logError: anErrorObject 
    self log: anErrorObject printString!

logging
    logging isNil ifTrue: [logging := self class loggingEnabled].
    ^logging!

logging: aBoolean 
    logging := aBoolean! !

!DatabaseAccessor methodsFor: 'login'!

login
    
    | warning |
    self loginIfError: [:ex | 
    	warning := 'Unable to log in. Check login information in DatabaseLoginResource class methods'.
    	Transcript show: warning; nl.
    	self showDialog: warning.
    	ex pass].
    "Just to help avoid confusion if someone thinks they're getting a login object back from this"
    ^nil.!

loginIfError: aBlock
    self subclassResponsibility.!

logout
    ^self subclassResponsibility.!

showDialog: aString
    self subclassResponsibility.! !

!DatabaseAccessor methodsFor: 'initializing'!

initialize!
reset! !

!DatabaseAccessor methodsFor: 'copying'!

copy
    ^self shallowCopy postCopy.!

postCopy! !

!DatabaseAccessor class methodsFor: 'instance creation'!

classForThisPlatform
    Dialect isGNU ifTrue: [^Smalltalk Glorp DBIDatabaseAccessor].
    Dialect isSqueak ifTrue: [^Dialect smalltalkAt: #SqueakDatabaseAccessor].
    Dialect isVisualWorks ifTrue: [^Dialect smalltalkAt: #'Glorp.VWDatabaseAccessor'].
    Dialect isVisualAge ifTrue: [^Dialect smalltalkAt: #VA55DatabaseAccessor].
    Dialect isDolphin ifTrue: [^Dialect smalltalkAt: #DolphinDatabaseAccessor].
    self error: 'unknown dialect'!

forLogin: aLogin 
    ^self classForThisPlatform new currentLogin: aLogin!

new
    ^super new initialize.! !

!DatabaseAccessor class methodsFor: 'accessing'!

loggingEnabled
    LoggingEnabled isNil ifTrue: [LoggingEnabled := false].
    ^LoggingEnabled!

loggingEnabled: aBoolean 
    LoggingEnabled := aBoolean! !

!DatabaseAccessor class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DataElementBuilder methodsFor: 'building objects'!

buildObjectFrom: anArray
    self row: anArray.
    instance := self valueOf: expression.!

findInstanceForRow: aRow useProxy: useProxies
    ^self.! !

!DataElementBuilder methodsFor: 'selecting fields'!

fieldsForSelectStatement
    ^Array with: expression.!

fieldsFromMyPerspective
    ^expression mappedFields.! !

!DataElementBuilder class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DoubleType methodsFor: 'converting'!

converterForStType: aClass
    ^self platform converterNamed: #numberToDouble.!

impliedSmalltalkType
    ^Dialect doublePrecisionFloatClass.! !

!DoubleType methodsFor: 'initialize'!

initialize
    super initialize.
    typeString := 'float8'.! !

!DoubleType class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!PluggableDatabaseConverter methodsFor: 'accessing'!

dbToStConverter: aBlock
    dbToSt := aBlock.!

stToDbConverter: aBlock
    stToDb := aBlock.! !

!PluggableDatabaseConverter methodsFor: 'converting'!

convert: anObject fromDatabaseRepresentationAs: aDatabaseType 
    ^dbToSt isNil ifTrue: [anObject] ifFalse: [dbToSt value: anObject]!

convert: anObject toDatabaseRepresentationAs: aDatabaseType 
    ^stToDb isNil ifTrue: [anObject] ifFalse: [stToDb value: anObject]! !

!PluggableDatabaseConverter class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabasePlatform methodsFor: 'testing'!

canBind: aValue to: aType
    (Dialect unbindableClassNames includes: aValue class name) ifTrue: [^false].
    ^true.!

supportsANSIJoins
    "Do we support the JOIN <tableName> USING <criteria> syntax. Currently hard-coded, but may also vary by database version"
    ^false.!

supportsBinding
    "Return true if this platform supports binding parameters rather than printing them as strings into the SQL statement"
    ^false.!

supportsCaseInsensitiveLike
    ^false.!

useBinding
    "Return true if we should use binding"

    self supportsBinding ifFalse: [^false].
    useBinding isNil ifTrue: [useBinding := self class useBindingIfSupported].
    ^useBinding!

useBinding: aBoolean
    useBinding := aBoolean.!

useMicrosoftOuterJoins
    "Return true if we use the Microsoft x *= y syntax for outer joins"
    ^false.!

useOracleOuterJoins
    "Return true if we use the old Oracle x = y (+) syntax for outer joins"
    ^false.! !

!DatabasePlatform methodsFor: 'types'!

char
    ^self typeNamed: #char ifAbsentPut: [CharType new].!

char: anInteger
    ^self char width: anInteger.!

character
    ^self char!

datetime
    ^self timestamp!

inMemorySequence
    ^self typeNamed: #inMemorySequence ifAbsentPut: [
    	InMemorySequenceDatabaseType representedBy: self int4].!

int4
    ^self subclassResponsibility!

integer
    ^self typeNamed: #integer ifAbsentPut: [IntegerDatabaseType new].!

sequence
    ^self subclassResponsibility!

smallint
    ^self typeNamed: #smallint ifAbsentPut: [SmallintDatabaseType new].!

text
    ^self typeNamed: #text ifAbsentPut: [TextType new].!

timestamp
    self subclassResponsibility.!

typeNamed: aSymbol ifAbsentPut: aBlock
    | type |
    type := self types at: aSymbol ifAbsentPut: [
    	| newType |
    	newType := aBlock value.
    	newType platform: self].
    type hasParameters ifTrue: [type := type copy].
    ^type.!

types
    types == nil ifTrue: [types := IdentityDictionary new].
    ^types.!

varChar
    ^self varchar.!

varchar
    ^self subclassResponsibility.!

varChar: anInt
    ^self varchar width: anInt.!

varchar: anInt
    ^self varchar width: anInt.! !

!DatabasePlatform methodsFor: 'services tables'!

createTableFKContraintsStatementStringsFor: aGLORPDatabaseTable
    | commandString commands addString |
    commands := OrderedCollection new.
    commandString := 'alter table'.
    addString := 'add'.
    self capitalWritingOfSQLCommands ifTrue: [	commandString := commandString asUppercase.
    											addString := addString asUppercase].
    self supportsConstraints
    		ifTrue: [aGLORPDatabaseTable foreignKeyConstraints
    					do: [:eachKeyField |
    							| sqlStatementStream |
    							sqlStatementStream := WriteStream on: String new.
    							sqlStatementStream
    								nextPutAll: commandString;
    								space.
    							self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.
    							sqlStatementStream
    								space;
    								nextPutAll: addString;
    								space;
    								nextPutAll: eachKeyField creationString.
    							commands add: sqlStatementStream contents]].
    ^commands!

createTableStatementStringFor: aGLORPDatabaseTable 
    "^<String> This method returns a string which can be used to create a database table ..."

    | sqlStatementStream tmpString |
    tmpString := 'create table'.
    sqlStatementStream := WriteStream on: String new.
    sqlStatementStream
    	nextPutAll: (self capitalWritingOfSQLCommands 
    				ifTrue: [tmpString asUppercase]
    				ifFalse: [tmpString]);
    	space.
    self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.

    "Now print the columns specification for each field in the table ..."
    self printColumnsSpecificationFor: aGLORPDatabaseTable
    	on: sqlStatementStream.
    (self supportsConstraints 
    	and: [aGLORPDatabaseTable hasPrimaryKeyConstraints]) 
    		ifTrue: 
    			[sqlStatementStream nextPutAll: ', '.
    			self printPrimaryKeyConstraintsOn: sqlStatementStream
    				for: aGLORPDatabaseTable].

    sqlStatementStream
    	nextPut: $).
    ^sqlStatementStream contents!

dropTableStatementStringFor: aGLORPDatabaseTable 
    "^<String> This method returns a string which can be used to drop a database table ..."

    | sqlStatementStream tmpString |
    tmpString := 'drop table'.
    sqlStatementStream := WriteStream on: String new.
    sqlStatementStream
    	nextPutAll: (self capitalWritingOfSQLCommands 
    				ifTrue: [tmpString asUppercase]
    				ifFalse: [tmpString]);
    	space.
    self printDDLTableNameFor: aGLORPDatabaseTable on: sqlStatementStream.
    ^sqlStatementStream contents!

nameForColumn: aColumnString
    ^aColumnString.!

printDDLTableNameFor: aGLORBDatabaseTable on: sqlStatementStream
    "This method just writes the name of a table to a stream"
    
    (aGLORBDatabaseTable schema asString isEmpty not 
    	and: [ self prefixQualifierBeforeCreatingAndDeleting ]) ifTrue:[
    		sqlStatementStream
    			nextPutAll: (self capitalWritingOfCreatorName 
    									ifTrue:[  aGLORBDatabaseTable creator asUppercase ] 
    									ifFalse:[aGLORBDatabaseTable creator ]) ;
    			nextPutAll: self prefixQualifierSeparatorString.
    ].
    sqlStatementStream
    	nextPutAll: (self capitalWritingOfTableName 
    							ifTrue:[ aGLORBDatabaseTable name asUppercase ] 
    							ifFalse:[ aGLORBDatabaseTable name ]).!

printForeignKeyConstraintsOn: sqlStatementStream for: aGLORBDatabaseTable
    "This method print the constraint specification on sqlStatementStream"
 
    | sepFlag |

    sepFlag := false.
    aGLORBDatabaseTable foreignKeyConstraints do: [ :eachKeyField |
    	sepFlag ifTrue:[ sqlStatementStream nextPutAll: ',' ].
    	sqlStatementStream nextPutAll: eachKeyField creationString.
    	sepFlag := true
    ].!

printPrimaryKeyConstraintsOn: sqlStatementStream for: aTable 
    "This method print the constraint specification on sqlStatementStream"

    | sepFlag |
    aTable primaryKeyFields isEmpty ifTrue: [^self].
    sqlStatementStream
    	nextPutAll: 'CONSTRAINT ';
    	nextPutAll: aTable primaryKeyConstraintName;
    	nextPutAll: ' PRIMARY KEY  ('.
    sepFlag := false.
    aTable primaryKeyFields do: 
    		[:eachPrimaryKeyField | 
    		sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
    		sqlStatementStream nextPutAll: eachPrimaryKeyField name.
    		sepFlag := true].
    sqlStatementStream nextPut: $).
    self primaryKeysAreAutomaticallyUnique ifTrue: [^self].
    sqlStatementStream
    	nextPutAll: ',';
    	nl;
    	nextPutAll: 'CONSTRAINT ';
    	nextPutAll: aTable primaryKeyUniqueConstraintName;
    	nextPutAll: ' UNIQUE  ('.
    sepFlag := false.
    aTable primaryKeyFields do: 
    		[:eachPrimaryKeyField | 
    		sepFlag ifTrue: [sqlStatementStream nextPutAll: ','].
    		sqlStatementStream nextPutAll: eachPrimaryKeyField name.
    		sepFlag := true].
    sqlStatementStream nextPut: $)!

validateTableName: tableNameString
    " <Boolean> I return true, if the choosen tableNameString is valid for the platform"

 	^( tableNameString size <= self maxLengthOfTableName ) 
    		and: [ (self predefinedKeywords includes: tableNameString asLowercase) not ]! !

!DatabasePlatform methodsFor: 'conversion-strings'!

padString: aString for: aType 
    | padding |
    aString isNil ifTrue: [^nil].
    (self usesNullForEmptyStrings and: [aString isEmpty]) ifTrue: [^nil].
    aString size > aType width 
    			ifTrue: [^aString copyFrom: 1 to: aType width].
    			
    aType isVariableWidth ifTrue: [^aString].
    padding := String new: aType width - aString size.
    padding atAllPut: 1 asCharacter.
    ^aString , padding!

stringToStringConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #padString:for: fromDbToSt: #unpadString:for:.!

stringToSymbol: aString for: aType
    ^(self unpadString: aString for: aType) asSymbol!

symbolToString: aSymbol for: aType
    ^self padString: aSymbol asString for: aType!

symbolToStringConverter
    ^DelegatingDatabaseConverter
    			hostedBy: self fromStToDb: #symbolToString:for: fromDbToSt: #stringToSymbol:for:.!

unpadString: aString for: aType
    aString isNil ifTrue: [^self usesNullForEmptyStrings ifTrue: [''] ifFalse: [nil]].
    ^aType isVariableWidth 
    	ifTrue: [aString]
    	ifFalse: [(ReadStream on: aString) upTo: 1 asCharacter].! !

!DatabasePlatform methodsFor: 'constants'!

areSequencesExplicitlyCreated
    self subclassResponsibility.!

batchWriteStatementTerminatorString
    "^<String> This statement return the string to be used to devide several statement during batch write ..."

    ^';'!

capitalWritingOfColumnName
    "^<Boolean> This method returns true, if the dbms wants to have column 
    names written in capital letters"

    ^true!

capitalWritingOfCreatorName
    "^<Boolean> This method returns true, if the dbms wants to have column 
    names written in capital letters"

    ^true!

capitalWritingOfDatabaseName
    "^<Boolean>"

    ^true!

capitalWritingOfSQLCommands
    "^<Boolean>"

    ^true!

capitalWritingOfTableName
    "^<Boolean>"

    ^true!

columnNameSeparatorString
    "^<String> This statement return the string to be used to devide several columns ..."

    ^','!

deleteViewWithTableSyntax
    ^false!

hasSubtransaction
    "^<Boolean> This method returns true, if the used dbms is able to execute multiple sql-statements
    transferred via a command line transmitted from client to server - otherwise I return false"

    ^true!

initializeReservedWords
    reservedWords := Dictionary new.!

maxLengthOfColumnName
    "^<Integer> I return the max. length of a column name"

    ^18!

maxLengthOfDatabaseName
    "^<Integer>I return the max. length of a database name"

    ^8!

maxLengthOfTableName
    "^<Integer> I return the max. length of a table name"

    ^18!

maxSQLBufferLength
    "^<Integer> I return the maximum length of a sql command stream"

    ^8192!

postfixTableNameBeforeDeleting
    ^false!

prefixQualifierBeforeCreatingAndDeleting
    ^true!

prefixQualifierSeparatorString
    "^<String> This statement return the string to be used to separate the qualifier and the table/column name"

    ^'.'!

prefixTableNameBeforeDeleting
    ^false!

primaryKeysAreAutomaticallyUnique
    "Return false if, in addition to specifying something as a primary key, we must separately specify it as unique"

    ^false.!

reservedWords
    reservedWords isNil ifTrue: [self initializeReservedWords].
    ^reservedWords.!

sqlTextForBeginTransaction
    "comment"

    ^'BEGIN'!

sqlTextForDecimalAttributeType: length post: postLength
    "^<String>"

    ^'DECIMAL(',length asString,',',postLength asString,')'!

sqlTextForDoubleAttributeType: length
    "^<String>"

    ^'FLOAT'!

sqlTextForDoubleLongIntegerAttributeType: length
    "^<String>"

    ^''!

sqlTextForFloatAttributeType: length
    "^<String>"

    ^'FLOAT'!

sqlTextForIntegerAttributeType: length
    "^<String>"

    ^'SMALLINT'!

sqlTextForLongIntegerAttributeType: length
    "^<String>"

    ^'INTEGER'!

sqlTextForNOTNULLAttributeConstraint
    "^<String>"

    ^'NOT NULL'!

sqlTextForNOTNULLWithDefaultAttributeConstraint
    "^<String>"

    ^'NOT NULL WITH DEFAULT'!

sqlTextForNOTUNIQUEAttributeConstraint
    ^''.!

sqlTextForNULLAttributeConstraint
    "^<String>"

    ^'NULL'!

sqlTextForTextAttributeType: length
    "^<String>"

    ^'LONG'!

sqlTextForTimeAttributeType
    "^<String>"

    ^'TIME'!

sqlTextForTimestampAttributeType
    "^<String>"

    ^'TIMESTAMP'!

sqlTextForUNIQUEAttributeConstraint
    ^'UNIQUE'.!

sqlTextForVariableCharAttributeType: length
    "^<String>"

    ^'VARCHAR(',length asString,')'!

sqlWildcardForMultipleCharacters
    "^<String> This method returns the used wildcard string for multiple characters"
    
    ^'%'!

sqlWildcardForSingleCharacter
    "^<String> This method returns the used wildcard string for single characters"
    
    ^'_'!

supportsConstraints
    "Return true if we support integrity constraints"
    ^true.!

supportsMillisecondsInTimes
    self subclassResponsibility.!

supportsVariableSizedNumerics
    "Return true if this platform can support numbers with a varying size and number of decimal places. Access, notably, doesn't seem to be able to"
    ^true.!

usesNullForEmptyStrings
    "Return true if this database is likely to use nil as an empty string value"
    ^false.!

usesNullForFalse
    "Return true if this database is likely to use nil as an empty string value"
    ^false.! !

!DatabasePlatform methodsFor: 'conversion-numbers'!

convertToDouble: aNumber for: aType 
    aNumber isNil ifTrue: [^nil].
    ^Dialect coerceToDoublePrecisionFloat: aNumber!

convertToFloat: aNumber for: aType 
    aNumber isNil ifTrue: [^nil].
    ^aNumber asFloat.!

convertToInteger: aNumber for: aType 
    ^aNumber isNil ifTrue: [aNumber] ifFalse: [aNumber asNumber asInteger].!

numberToDoubleConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #convertToDouble:for: fromDbToSt: #convertToDouble:for:.!

numberToFloatConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #convertToFloat:for: fromDbToSt: #convertToFloat:for:.!

numberToIntegerConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #convertToInteger:for: fromDbToSt: #convertToInteger:for:.! !

!DatabasePlatform methodsFor: 'conversion-boolean'!

booleanToBooleanConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #convertBooleanToDBBoolean:for: fromDbToSt: #convertDBBooleanToBoolean:for:.!

booleanToIntegerConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #convertBooleanToInteger:for: fromDbToSt: #convertIntegerToBoolean:for:.!

booleanToStringTFConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: #convertBooleanToTF:for: fromDbToSt: #convertTFToBoolean:for:.!

convertBooleanToDBBoolean: aBoolean for: aType
    (self usesNullForFalse and: [aBoolean isNil]) ifTrue: [^false].
    ^aBoolean.!

convertBooleanToInteger: aBoolean for: aType
    aBoolean isNil ifTrue: [^nil].
    ^aBoolean ifTrue: [1] ifFalse: [0].!

convertBooleanToTF: aBoolean for: aType
    aBoolean isNil ifTrue: [^aBoolean].
    ^aBoolean ifTrue: ['T'] ifFalse: ['F'].!

convertDBBooleanToBoolean: aBoolean for: aType
    ^aBoolean.!

convertIntegerToBoolean: anInteger for: aType
    anInteger isNil ifTrue: [^anInteger].
    anInteger = 1 ifTrue: [^true].
    anInteger = 0 ifTrue: [^false].
    self error: 'invalid boolean conversion'.!

convertTFToBoolean: aString for: aType
    aString isNil ifTrue: [^aString].
    aString = 'T' ifTrue: [^true].
    aString = 'F' ifTrue: [^false].
    self error: 'invalid boolean conversion'.! !

!DatabasePlatform methodsFor: 'conversion-times'!

dateConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: "#printDate:for:" #nullConversion:for: fromDbToSt: #readDate:for:.!

printDate: aTimestamp isoFormatOn: stream
    "Print the date as yyyy-mm-dd"
    | monthNumber dayOfMonth |
    aTimestamp isNil ifTrue: [^'NULL'].
    aTimestamp year printOn: stream.
    stream nextPut: $-.
    monthNumber := (Dialect isVisualWorks and: [aTimestamp class == Date]) ifTrue: [aTimestamp monthIndex] ifFalse: [aTimestamp month].
    stream nextPutAll: (DatabaseType padToTwoDigits: monthNumber).
    stream nextPut: $-.
    dayOfMonth := (aTimestamp class == Date) ifTrue: [aTimestamp dayOfMonth] ifFalse: [aTimestamp day].
    stream nextPutAll: (DatabaseType padToTwoDigits: dayOfMonth).!

printTime: aTimestamp isoFormatOn: stream
    self printTime: aTimestamp isoFormatOn: stream milliseconds: self supportsMillisecondsInTimes!

printTime: aTimestamp isoFormatOn: stream milliseconds: aBoolean
    "Print the time as hh:mm:ss.mmm"
    | ms |
    aTimestamp isNil ifTrue: [^nil].
    stream nextPutAll: (DatabaseType padToTwoDigits: aTimestamp hours).
    stream nextPut: $:.
    stream nextPutAll: (DatabaseType padToTwoDigits: aTimestamp minutes).
    stream nextPut: $:.
    stream nextPutAll: (DatabaseType padToTwoDigits: aTimestamp seconds).
    aBoolean ifFalse: [^self].
    ms := aTimestamp milliseconds.
    ms = 0 ifTrue: [^self].
    stream nextPut: $..
    ms < 100 ifTrue: [stream nextPut: $0].
    stream nextPutAll: (DatabaseType padToTwoDigits: ms).!

printTimestamp: aTimestamp for: aType
    ^( '''', aTimestamp printString, '''').!

readDate: anObject for: aType
    "format '2003-03-13"
    anObject isNil ifTrue: [^nil].
    anObject class == Date ifTrue: [^anObject].
    anObject isString ifTrue: [
    	^self readDateFromStream: (ReadStream on: anObject) for: aType].
    ^anObject asDate.!

readDateFromStream: aStream for: aType
    "Seems like we get to do this ourselves, in a lowest common denominator kind of way. Translate into GMT if we've got a timezone."
    "assumes ISO format.
    self readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.
    self readTimestamp: '2003-03-03 19:29:28.337-05' for: nil

"
    |  years months days |
    years := (aStream upTo: $-) asNumber.
    months := (aStream upTo: $-) asNumber.
    days := (aStream upTo: $ ) asNumber.
    ^Dialect newDateWithYears: years months: months days: days.!

readTime: anObject for: aType
    "format 15:29:28.337-05  (timezone optional)"
    anObject isNil ifTrue: [^nil].
    anObject class == Time ifTrue: [^anObject].
    anObject isString ifTrue: [
    	^self readTimeFromStream: (ReadStream on: anObject) for: aType].
    ^anObject asTime.!

readTimeFromStream: aStream for: aType
    "Seems like we get to do this ourselves, in a lowest common denominator kind of way. Ignore timezones right now"
    "assumes ISO format.
    self readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.
    self readTimestamp: '2003-03-03 19:29:28.337-05' for: nil

"
    | hours minutes seconds milliseconds timeZoneOffset millisecondAccumulator |
    hours := (aStream upTo: $:) asNumber.
    minutes := (aStream upTo: $:) asNumber.
    seconds := (aStream next: 2) asNumber.
    (aStream peek = $.) 
    	ifTrue: [
    		aStream next.
    		millisecondAccumulator := WriteStream on: String new.
    		[aStream atEnd not and: [aStream peek isDigit]] whileTrue: [
    			millisecondAccumulator nextPut: aStream next].
    		milliseconds := millisecondAccumulator contents asNumber]
    	ifFalse: [milliseconds := 0].
    timeZoneOffset := aStream upToEnd asNumber.
    ^Dialect newTimeWithHours: hours minutes: minutes seconds: seconds milliseconds: milliseconds.
    "^Dialect addSeconds: (timeZoneOffset * -1* 60 * 60) to: aTime."!

readTimestamp: anObject for: aType
    "Seems like we get to do this ourselves, in a lowest common denominator kind of way. Translate into GMT if we've got a timezone."

    "assumes ISO format.
    self readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.
    self readTimestamp: '2003-03-03 19:29:28.337-05' for: nil"

    anObject isNil ifTrue: [^nil].
    anObject class == Dialect timestampClass ifTrue: [^anObject].
    anObject isString
    	ifTrue:
    		[| stream |
    		stream := ReadStream on: anObject.
    		^self readTimestampFromStream: stream for: aType].
    ^anObject asTimestamp.!

readTimestampFromStream: aStream for: aType
    | years months days hours minutes seconds millisecondAccumulator milliseconds timeZoneOffset |
    years := (aStream upTo: $-) asNumber.
    months := (aStream upTo: $-) asNumber.
    days := (aStream upTo: $ ) asNumber.
    hours := (aStream upTo: $:) asNumber.
    minutes := (aStream upTo: $:) asNumber.
    seconds := (aStream next: 2) asNumber.
    (aStream peek = $.) 
    	ifTrue: [
    		aStream next.
    		millisecondAccumulator := WriteStream on: String new.
    		[aStream atEnd not and: [aStream peek isDigit]] whileTrue: [
    			millisecondAccumulator nextPut: aStream next].
    		milliseconds := millisecondAccumulator contents asNumber]
    	ifFalse: [milliseconds := 0].
    timeZoneOffset := aStream upToEnd asNumber * 60 * 60.
    ^Dialect 
    	newTimestampWithYears: years
    	months: months
    	days: days
    	hours: hours
    	minutes: minutes
    	seconds: seconds
    	milliseconds: milliseconds
    	offset:timeZoneOffset.!

timeConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: "#printTime:for:" #nullConversion:for: fromDbToSt: #readTime:for:.!

timestampConverter
    ^DelegatingDatabaseConverter
    	hostedBy: self fromStToDb: "#printTimestamp:for:" #nullConversion:for: fromDbToSt: #readTimestamp:for:.! !

!DatabasePlatform methodsFor: 'type converters'!

converterNamed: aSymbol
    ^self converters at: aSymbol ifAbsentPut: [
    	| converter |
    	converter := self perform: (aSymbol, 'Converter') asSymbol.
    	converter name: aSymbol]!

converters
    converters isNil ifTrue: [converters := IdentityDictionary new].
    ^converters.! !

!DatabasePlatform methodsFor: 'general services'!

predefinedKeywords
    "
    	^<OrderdCollection of: String> This method returns a list of preserved keyword, which should
    	not be used in database-, table or column names or any othe names in the platform system
    "

    ^OrderedCollection new! !

!DatabasePlatform methodsFor: 'conversion-null'!

nullConversion: anObject for: aType
    ^anObject.!

nullConverter
    ^DelegatingDatabaseConverter
    		hostedBy: self fromStToDb: #nullConversion:for: fromDbToSt: #nullConversion:for:! !

!DatabasePlatform methodsFor: 'sequences'!

databaseSequenceClass
    self subclassResponsibility.!

newDatabaseSequenceNamed: aString
    "Return a sequence of the type we use, with the given name"
    ^self databaseSequenceClass named: aString.! !

!DatabasePlatform methodsFor: 'services columns'!

printColumnsSpecificationFor: aGLORBDatabaseTable on: sqlStatementStream
    aGLORBDatabaseTable fields isEmpty not
    	ifTrue:
    		[| sepFlag |
    		sqlStatementStream
    			space;
    			nextPut: $(.
    		sepFlag := false.
    		aGLORBDatabaseTable fields
    			do:
    				[:eachGLORBDatabaseField | 
    				sepFlag ifTrue: [sqlStatementStream nextPutAll: self columnNameSeparatorString].
    				sqlStatementStream
    					nextPutAll:
    							(self capitalWritingOfColumnName
    									ifTrue: [eachGLORBDatabaseField name asUppercase]
    									ifFalse: [eachGLORBDatabaseField name]);
    					space;
    					nextPutAll: eachGLORBDatabaseField typeString;
    					space;
    					nextPutAll:
    							(eachGLORBDatabaseField isNullable
    									ifTrue: [self sqlTextForNULLAttributeConstraint]
    									ifFalse: [self sqlTextForNOTNULLAttributeConstraint]);
    					space;
    					nextPutAll:
    							(eachGLORBDatabaseField isUnique
    									ifTrue: [self sqlTextForUNIQUEAttributeConstraint]
    									ifFalse: [self sqlTextForNOTUNIQUEAttributeConstraint]).
    				sepFlag := true]].! !

!DatabasePlatform class methodsFor: '*eoglorp'!

createLoginFromConnectionDictionary: aDict 
    self subclassResponsibility!

loginWithConnectionDictionary: aDict 
    | platformClass |
    platformClass := self allSubclasses
    			detect: [:cls | cls understandsConnectionDictionary: aDict].
    ^ platformClass isNil
    	ifFalse: [platformClass createLoginFromConnectionDictionary: aDict] ifTrue: [nil]!

understandsConnectionDictionary: aDict
    ^false! !

!DatabasePlatform class methodsFor: 'accessing'!

useBindingIfSupported
    UseBindingIfSupported isNil ifTrue: [UseBindingIfSupported := false].
    ^UseBindingIfSupported!

useBindingIfSupported: aBoolean 
    UseBindingIfSupported := aBoolean! !

!DatabasePlatform class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!SimpleQuery methodsFor: 'executing'!

buildObjectsFromRow: anArray
    | buildersThatReturnResults |
    builders
    	do:
    		[:each | each findInstanceForRow: anArray useProxy: self returnProxies].
    builders do: [:each | each buildObjectFrom: anArray].
    builders do: [:each | each knitResultIn: self].
    buildersThatReturnResults := builders
    	select: [:each | tracing retrievalExpressions includes: each expression].
    buildersThatReturnResults do: [:each |
    	each expression canBeUsedForRetrieve ifFalse: [self error: 'illegal argument for #retrieve: ', each printString, '. Use alsoFetch: instead']].

    ^buildersThatReturnResults size = 1
    	ifTrue: [buildersThatReturnResults first instance]
    	ifFalse: [buildersThatReturnResults collect: [:each | each instance]].!

buildObjectsFromRows: anArray
    "Build the result list from the given rows, eliminating duplicates (which may be caused by joins)"

    ^self mightHaveDuplicateRows
    	ifTrue: [self buildObjectsFromRowsRemovingDuplicates: anArray]
    	ifFalse: [ | result |
    		result := (self collectionType new: anArray size) writeStream.
    		anArray do: [:each | result nextPut: (self buildObjectsFromRow: each)].
    		result contents].!

buildObjectsFromRowsRemovingDuplicates: anArray
    	
    | resultSet results |
    resultSet := Set new: anArray size.
    results := (self collectionType new: anArray size) writeStream.
    anArray do: [:each | | row |
    	row := self buildObjectsFromRow: each.
    	(resultSet includes: row)
    		ifFalse: [
    			results nextPut: row.
    			resultSet add: row]].
    ^results contents.!

computeFields
    builders 
    	do: [:each | self computeFieldsFor: each]!

computeFieldsFor: anElementBuilder 
    | translatedFields |
    translatedFields := self 
    	addFields: anElementBuilder fieldsForSelectStatement
    	returningTranslationForFields: anElementBuilder fieldsFromMyPerspective
    	distinct: anElementBuilder requiresDistinct.
    anElementBuilder fieldTranslations: translatedFields.!

readFromDatabaseWithParameters: anArray
    | rows objects valueToReturn |
    rows := self rowsFromDatabaseWithParameters: anArray.
    objects := self buildObjectsFromRows: rows.
    objects do: [:each | session sendPostFetchEventTo: each].
    valueToReturn := readsOneObject
    	ifTrue: [objects isEmpty ifTrue: [self absentBlock value] ifFalse: [objects first]]
    	ifFalse: [self resultCollectionFor: objects].
    session register: valueToReturn.
    ^valueToReturn.!

resultCollectionFor: objects
    | results |
    collectionType isNil ifTrue: [^objects].
    collectionType == objects class ifTrue: [^objects].
    results := collectionType new: objects size.
    results addAll: objects.
    ^results.!

rowsFromDatabaseWithParameters: anArray
    self shortCircuitEmptyReturn ifTrue: [^#()].
    ^session reusePreparedStatements
    	ifTrue:
    		[session accessor
    			executeCommandReusingPreparedStatements: (self sqlWith: anArray)]
    	ifFalse: [session accessor executeCommand: (self sqlWith: anArray)].!

setUpCriteria
    super setUpCriteria.
    self validateCriteria.! !

!SimpleQuery methodsFor: 'preparing'!

addJoin: anExpression
    joins addAll: anExpression asIndependentJoins.!

assignTableAliases
    | tableNumber allExpressions |
    criteria isPrimaryKeyExpression ifTrue: [^self].
    tableNumber := 1.
    allExpressions := ExpressionGroup with: criteria.
    allExpressions addAll: ordering.
    allExpressions addAll: joins.
    builders do: [:each | allExpressions add: each expression]. 
    allExpressions do: [:each |
    	"Assume that prepare is all-or-nothing. If any of these nodes has aliases, it means everything was already aliased, possibly in another query instance that shares our criterion"
    	each hasTableAliases ifTrue: [^self].
    	tableNumber := each assignTableAliasesStartingAt: tableNumber].!

fixJoins
    | pseudoJoins realJoins |
    pseudoJoins := joins select: [:each | each tablesForANSIJoin size < 2].
    pseudoJoins do: [:each | criteria := each AND: criteria].
    realJoins :=  joins select: [:each| each tablesForANSIJoin size >= 2].
    joins := realJoins.!

isPrepared
    ^prepared.!

prepare
    prepared ifTrue: [^self].
    self setUpCriteria. "Just in case it hasn't already been done"
    self setupTracing.
    criteria prepareIn: self.
    self fixJoins.
    self assignTableAliases.
    self computeFields.
    prepared := true.!

setupTracing
    builders isNil ifFalse: [^self].  "Already been done"

    super setupTracing.
    builders := tracing allTracings asArray collect: [:each | ElementBuilder for: each in: self].!

traceExpressionInContextFor: anExpression 
    
    ^anExpression rebuildOn: criteria ultimateBaseExpression.! !

!SimpleQuery methodsFor: 'testing'!

hasTracing
    "Return true if we've given this query a tracing already"
    ^builders notNil.!

mightHaveDuplicateRows
    ^builders anySatisfy: [:each | each canCauseDuplicateRows].!

requiresFullQuery
    ^self descriptor classesRequiringIndependentQueries size > 1!

shortCircuitEmptyReturn
    "If we have a literal false for criteria, we never need to go to the database"
    ^criteria class == EmptyExpression and: [criteria isFalse].!

useANSIJoins
    ^self session platform supportsANSIJoins.! !

!SimpleQuery methodsFor: 'sql generation'!

printANSITablesOn: aCommand
    "Print ourselves using the JOIN... USING syntax. Note that we have to put the joins in the right order because we're not allowed to refer to tables not mentioned yet. Great syntax. Reminds me of Pascal. And so easy to deal with."

    | printer |
    printer := JoinPrinter for: self.
    printer printJoinsOn: aCommand.!

printCriteriaOn: aCommand
    self hasEmptyWhereClause
    	ifFalse:
    		[aCommand
    			nl;
    			nextPutAll: ' WHERE '.
    		criteria printSQLOn: aCommand withParameters: aCommand parameters].!

printJoinsOn: aCommand
    | noLeadIn|
    self platform supportsANSIJoins ifTrue: [^self].
    joins isEmpty ifTrue: [^self].
    noLeadIn := criteria isEmptyExpression.
    noLeadIn ifFalse: [aCommand nextPutAll: ' AND ('].
    GlorpHelper 
    		do: [:each | each printSQLOn: aCommand withParameters: aCommand parameters]
    		for: joins
    		separatedBy: [aCommand nextPutAll: ' AND '].
    noLeadIn ifFalse: [aCommand nextPut: $)].!

printNormalTablesOn: aCommand
    self printNormalTablesOn: aCommand excluding: #().!

printNormalTablesOn: aCommand excluding: aCollection
    | tablesToPrint |
    tablesToPrint := self tablesToPrint.
    aCollection do: [:each | tablesToPrint remove: each].
    GlorpHelper
    	print: [:table | table sqlTableName]
    	on: aCommand
    	for: tablesToPrint
    	separatedBy: ', '.
    ^tablesToPrint.!

printOrderingOn: aStream
    ordering isNil ifTrue: [^self].
    aStream nextPutAll: ' ORDER BY '.
    GlorpHelper
    	do: [:each | each printSQLOn: aStream withParameters: nil]
    	for: ordering
    	separatedBy: [aStream nextPutAll: ', '].!

printSelectFields: aCollection on: stream 
    GlorpHelper 
    	print: [:field | field printSQLOn: stream withParameters: nil. '']
    	on: stream
    	for: aCollection
    	separatedBy: ', '!

printSelectFieldsOn: stream 
     distinctFields notNil ifTrue: [stream nextPutAll: 'DISTINCT '].
     self printSelectFields: fields on: stream!

printTablesOn: aCommand
    aCommand
    	nl;
    	nextPutAll: ' FROM '.
    self useANSIJoins
    	ifTrue: [self printANSITablesOn: aCommand]
    	ifFalse: [self printNormalTablesOn: aCommand].!

signature
    session useBinding ifFalse: [^''].
    ^self sqlWith: Dictionary new.!

sqlWith: aDictionary
    self prepare.
    ^SelectCommand
    	forQuery: self
    	parameters: aDictionary
    	useBinding: session useBinding
    	platform: session platform.!

tablesToPrint
    | allTables base |
    base := criteria ultimateBaseExpression.
"	allTables :=  (fields collect: [:each | base aliasedTableFor: each table ifAbsent: [nil]]) asSet."
    allTables := (fields collect: [:each | each table]) asSet.
    allTables addAll: criteria allTablesToPrint.
    joins do: [:eachJoin |
    	allTables addAll: eachJoin allTablesToPrint].
    ordering isNil ifFalse: [ordering do: [:each | allTables add: each field table]].
    self tracing allTracings do: [:each | allTables addAll: each allTablesToPrint].
    ^allTables asSortedCollection.! !

!SimpleQuery methodsFor: 'accessing'!

builders
    ^builders.!

criteria: anExpression
    criteria := anExpression!

elementBuilderFor: anExpression 
    ^builders detect: [:each | each expression == anExpression] ifNone: [nil].!

fields
    ^fields!

joins
    ^joins.!

platform
    ^session system platform.! !

!SimpleQuery methodsFor: 'initialize'!

initResultClass: aClass criteria: theCriteria singleObject: aBoolean 
    super 
    	initResultClass: aClass
    	criteria: theCriteria
    	singleObject: aBoolean.
    prepared := false.
    fields := OrderedCollection new.
    joins := OrderedCollection new.! !

!SimpleQuery methodsFor: 'fields'!

addDistinctField: aField
    distinctFields isNil ifTrue: [distinctFields := OrderedCollection new].
    distinctFields add: aField.!

addFields: aliasedFields returningTranslationForFields: originalFields distinct: isDistinct 
    "The query has computed a set of fields the way the mappings see them, which are then transformed to account for field aliasing in embedded mappings. Add those to our collection, and set up the translation which knows which fields are at which index in the resulting row. If necessary, note that those fields are selected as distinct"

    | translation |
    translation := IdentityDictionary new.
    aliasedFields with: originalFields
    	do: 
    		[:aliased :original | 
    		| position |
    		position := fields indexOf: aliased.
    		position = 0 
    			ifTrue: 
    				[fields add: aliased.
    				position := fields size.
    				isDistinct ifTrue: [self addDistinctField: aliased]].
    		translation at: original put: position].
    ^translation! !

!SimpleQuery methodsFor: 'As yet unclassified'!

hasEmptyWhereClause
    "If we have regular where clause entries, or if we have joins that aren't going to be printed in the tables portion, then we're not empty"
    criteria isEmptyExpression ifFalse: [^false].
    self useANSIJoins ifTrue: [^true].
    ^joins isEmpty.! !

!SimpleQuery methodsFor: 'converting'!

asFullQuery
    | newQuery |
    newQuery := ReadQuery new
    	initResultClass: resultClass criteria: criteria singleObject: readsOneObject.
    newQuery returnProxies: self returnProxies.
    newQuery shouldRefresh: self shouldRefresh.
    newQuery setOrdering: ordering.
    newQuery collectionType: collectionType.
    ^newQuery.! !

!SimpleQuery methodsFor: 'copying'!

postCopy
    super postCopy.
    fields := OrderedCollection new.
    joins := OrderedCollection new.
    distinctFields := nil.
    builders := nil.! !

!SimpleQuery class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FieldValueWrapper methodsFor: 'containing'!

isNowContainedBy: aRow and: aField
    | thisRowsEntries shortCircuit |
    shortCircuit := false.
    thisRowsEntries := containedBy at: aRow ifAbsentPut: [shortCircuit := true. OrderedCollection with: aField].
    shortCircuit ifTrue: [^self].
    (thisRowsEntries includes: aField) ifFalse: [thisRowsEntries add: aField].! !

!FieldValueWrapper methodsFor: 'public'!

containedBy
    ^containedBy.!

contents
    ^contents.!

contents: anObject
    (hasValue and: [contents ~= anObject]) ifTrue: [self error: 'Inconsistent values in field'].
    contents := anObject.
    hasValue := true.!

hasValue
    ^hasValue.!

initialize
    hasValue := false.
    containedBy := IdentityDictionary new.!

printOn: aStream
    aStream 
    	nextPutAll: '<<'.
    self hasValue ifTrue: [aStream print: contents].
    aStream
    	nextPutAll: '>>'.! !

!FieldValueWrapper class methodsFor: 'public'!

new
    ^super new initialize.! !

!FieldValueWrapper class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!BaseExpression methodsFor: 'accessing'!

additionalExpressions
    | expressions |
    expressions := OrderedCollection new.
    descriptor typeMapping addTypeMappingCriteriaTo: expressions in: self.
    expressions addAll: self multipleTableExpressions.
    ^expressions!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. We don't have a base, but we *are* a base, so return true"
    ^true.!

descriptor
    ^descriptor!

descriptor: aDescriptor
    descriptor := aDescriptor!

hasDescriptor
    ^descriptor notNil.!

multipleTableExpressions
    ^self descriptor multipleTableCriteria 
    	collect: [:each | each asExpressionJoiningSource: self toTarget: self]!

system
    ^descriptor system.!

targetDescriptor
    self halt! !

!BaseExpression methodsFor: 'preparing'!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    ^source.!

controlsTables
    ^true.!

fieldsForSelectStatement
    ^descriptor mappedFields.!

rebuildOn: aBaseExpression 
    ^aBaseExpression.!

tables
    ^descriptor tables.!

tablesToPrint
    "We derive the base's tables from the fields that are being selected, but make sure that at least the primary table is listed."
    ^Array with: (self aliasedTableFor: descriptor primaryTable).! !

!BaseExpression methodsFor: 'printing'!

className
    ^'Base'.!

printOn: aStream 
    aStream
    	nextPutAll: self className;
    	nextPut: $(.
    self printTreeOn: aStream.
    aStream nextPut: $)!

printOnlySelfOn: aStream 
    descriptor isNil ifTrue: [aStream nextPutAll: 'Empty Base'. ^self].
    aStream print: descriptor describedClass.
    self printTableAliasesOn: aStream!

printTreeOn: aStream 
    aStream 
    	print: (descriptor isNil ifTrue: [nil] ifFalse: [descriptor describedClass])! !

!BaseExpression methodsFor: 'testing'!

canBeUsedForRetrieve
    "Return true if this is a valid argument for a retrieve: clause"
    ^true.! !

!BaseExpression methodsFor: 'api'!

base
    ^nil.!

getParameter: aDatabaseField 
    ^ParameterExpression forField: aDatabaseField basedOn: self.! !

!BaseExpression methodsFor: 'navigating'!

ultimateBaseExpression
    ^self! !

!BaseExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ParameterExpression methodsFor: 'accessing'!

base
    ^base!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^true.!

field
    ^field! !

!ParameterExpression methodsFor: 'navigating'!

ultimateBaseExpression
    ^base ultimateBaseExpression.! !

!ParameterExpression methodsFor: 'printing'!

printOn: aStream 
    aStream nextPutAll: 'Parameter('.
    self printTreeOn: aStream.
    aStream nextPut: $)!

printOnlySelfOn: aStream
    field printSQLOn: aStream withParameters: #()!

printSQLOn: aStream withParameters: aDictionary
    self field type print: (self valueIn: aDictionary) on: aStream.!

printTreeOn: aStream 
    field printSQLOn: aStream withParameters: #()!

valueIn: aDictionary 
    ^aDictionary at: field.! !

!ParameterExpression methodsFor: 'testing'!

canBind
    "Return true if this represents a value that can be bound into a prepared statement"
    ^true.! !

!ParameterExpression methodsFor: 'preparing'!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."

    ^source getField: field.! !

!ParameterExpression methodsFor: 'initialize/release'!

field: aDatabaseField base: aBaseExpression 
    field := aDatabaseField.
    base := aBaseExpression! !

!ParameterExpression methodsFor: 'As yet unclassified'!

rebuildOn: aBaseExpression
    ^aBaseExpression getParameter: field.! !

!ParameterExpression methodsFor: 'iterating'!

do: aBlock skipping: aSet
    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    base do: aBlock skipping: aSet.
    aBlock value: self.! !

!ParameterExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ParameterExpression class methodsFor: 'instance creation'!

forField: aField basedOn: anObjectExpression
    ^self new field: aField base: anObjectExpression; yourself! !

!CacheManager methodsFor: 'initialize/release'!

cacheForClass: aClass
    ^subCaches at: aClass
    	ifAbsentPut: [self makeCacheFor: aClass]!

initialize
    subCaches := IdentityDictionary new: 100.!

makeCacheFor: aClass 
    | rootClass cache |
    rootClass := session isNil ifTrue: [aClass] ifFalse: [session lookupRootClassFor: aClass].
    cache := subCaches at: rootClass ifAbsentPut: [ Cache newFor: rootClass in: self ].
    subCaches at: aClass put: cache.
    ^cache!

release
    subCaches do: [:each | each release].! !

!CacheManager methodsFor: 'querying'!

containsObjectForClass: aClass key: aKey
    | cache |
    cache := self cacheForClass: aClass.
    ^cache includesKey: aKey.!

hasExpired: anObject
    | key cache |
    key := (session descriptorFor: anObject) primaryKeyFor: anObject.
    cache := self cacheFor: anObject.
    cache isNil ifTrue: [^false].  "We have an uninstantiated proxy."
    ^cache hasExpired: key.!

hasExpired: aClass key: key
    | cache |
    cache := self cacheFor: aClass.
    ^cache hasExpired: key.!

hasObjectExpiredOfClass: aClass withKey: key
    | cache |
    cache := self cacheForClass: aClass.
    ^cache hasExpired: key.!

lookupClass: aClass key: aKey
    ^self lookupClass: aClass key: aKey ifAbsent: [self error: 'cache miss'].!

lookupClass: aClass key: aKey ifAbsent: failBlock
    | object |
    object := (self cacheForClass: aClass) at: aKey ifAbsent: failBlock.
    ^(object isKindOf: aClass)
    	ifTrue: [ object ]
    	ifFalse: [ failBlock value ].!

lookupClass: aClass key: aKey ifAbsentPut: failBlock
    ^(self cacheForClass: aClass) at: aKey ifAbsentPut: failBlock.!

markAsCurrentOfClass: aClass key: key
    | cache |
    aClass == Proxy ifTrue: [^self].
    cache := self cacheForClass: aClass.
    cache markAsCurrentAtKey: key.!

removeClass: aClass key: aKey
    ^self removeClass: aClass key: aKey ifAbsent: [self error: 'Object not in cache'].!

removeClass: aClass key: aKey ifAbsent: failBlock 
    | cache |
    cache := self cacheForClass: aClass.
    (cache includesKey: aKey withClass: aClass) ifFalse: [^failBlock value].
    cache removeKey: aKey ifAbsent: [ failBlock value ].! !

!CacheManager methodsFor: 'accessing'!

numberOfElements
    ^subCaches inject: 0 into: [:sum :each |
    	sum + each numberOfElements].!

session
    ^session.!

session: aSession 
    session := aSession.!

system
    ^self session system.! !

!CacheManager methodsFor: 'private/caching'!

cacheFor: anObject
    "Get the cache for a particular object. Since this could conceivably be passed a proxy, check for that. The cache for an uninstantiated proxy is kind of ambiguous, treat it as nil.  This could also be a class"

    | nonMetaClass |
    nonMetaClass := anObject isBehavior ifTrue: [anObject] ifFalse: [anObject class].
    ^nonMetaClass == Proxy
    	ifTrue: [anObject isInstantiated ifTrue: [self cacheFor: anObject getValue] ifFalse: [nil]]
    	ifFalse: [self cacheForClass: nonMetaClass].!

expiredInstanceOf: aClass key: aKey
    ^(self cacheForClass: aClass) expiredInstanceFor: aKey.! !

!CacheManager methodsFor: 'adding'!

at: aKey insert: anObject
    | subCache |
    subCache := self cacheForClass: anObject class.
    subCache at: aKey ifAbsentPut: [anObject].! !

!CacheManager class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!CacheManager class methodsFor: 'instance creation'!

forSession: aSession 
    ^self new session: aSession.!

new
    ^super new initialize.! !

!WeakVWCachePolicy methodsFor: 'accessing'!

dictionaryClass
    Dialect isGNU ifTrue: [ ^Dialect smalltalkAt: #WeakValueLookupTable ].
    ^Dialect smalltalkAt: #EphemeralValueDictionary ifAbsent: [Dictionary].!

numberOfReferencesToKeepAround
    ^numberOfElements.! !

!WeakVWCachePolicy methodsFor: 'initialize-release'!

newItemsIn: aCache
    | items |
    items := super newItemsIn: aCache.
    items manager: aCache.
    ^items.! !

!WeakVWCachePolicy methodsFor: 'expiry'!

collectionForExtraReferences
    ^FixedSizeQueue maximumSize: self numberOfReferencesToKeepAround.!

markEntryAsCurrent: item in: aCache
    aCache markEntryAsCurrent: item.! !

!WeakVWCachePolicy class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!IdentityTypeMapping methodsFor: 'testing'!

canBeTypeMappingParent
    ^false!

isAbstract
    ^false!

isTypeMappingRoot
    ^true! !

!IdentityTypeMapping methodsFor: 'mapping'!

mappedFields
    ^#()!

trace: aTracing context: anExpression
    "do nothing"! !

!IdentityTypeMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!HorizontalTypeMapping methodsFor: 'accessing'!

beAbstract
    isAbstract := true!

isAbstract
    ^isAbstract isNil ifTrue: [ isAbstract := false ] ifFalse: [ isAbstract ]! !

!HorizontalTypeMapping methodsFor: 'mapping'!

allDescribedConcreteClasses
    | col |
    col := OrderedCollection new
    	add: self describedClass;
    	addAll: self describedClass allSubclasses;
    	yourself.
    self needsWork: 'This belongs in someone else''s responsibility'.
    ^col select: [:each |
    	(self system descriptorFor: each) typeMapping isAbstract not ].!

mapFromObject: anObject intoRowsIn: aRowMap
    "do nothing"!

mappedFields
    ^#()!

referencedIndependentObjectsFrom: anObject
    ^#()!

trace: aTracing context: anExpression
    ^self! !

!HorizontalTypeMapping methodsFor: 'initializing'!

mappedClass: aClass
    mappedClass := aClass! !

!HorizontalTypeMapping class methodsFor: 'instance creation'!

forClass: aClass
    ^self new
    	mappedClass: aClass;
    	yourself! !

!HorizontalTypeMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!UnitOfWork methodsFor: 'begin/commit/abort'!

abort
    self reinitialize.!

begin
    self reinitialize.!

commit
    self preCommit.
    self writeRows.
    self postCommit!

createMementoRowMapFor: objects 
    "Create a rowmap for the objects whose state was already known. We subtract this from the rowmap of all known objects to get the rows that need to be written. New objects are also registered, so we only generate rows here for non-new objects"

    | localRowMap |
    localRowMap := RowMapForMementos 
    			withCorrespondenceMap: self correspondenceMap.
    objects keysAndValuesDo: 
    		[:original :memento | 
    		(self newObjects includes: original) 
    			ifFalse: [session createRowsFor: memento in: localRowMap]].
    ^localRowMap!

createRowMapFor: objects
    | localRowMap |
    localRowMap := RowMap new.
    objects do: [:each | session createRowsFor: each in: localRowMap].
    ^localRowMap!

createRows
    self createRowsForPartialWrites.!

createRowsForCompleteWrites
    "reference implementation. not called from anywhere"

    self registeredObjectsDo: [:eachObject | session createRowsFor: eachObject in: rowMap].
    self newObjects do: [:eachObject | session createRowsFor: eachObject in: rowMap].
    deletedObjects do: [:eachObject | session createDeleteRowsFor: eachObject in: rowMap].!

createRowsForPartialWrites
    | registeredObjectsRowMap mementoObjectsRowMap |
    registeredObjectsRowMap := self createRowMapFor: self registeredObjects.
    mementoObjectsRowMap := self createMementoRowMapFor: self mementoObjects.
    self newObjects 
    	do: [:eachObject | session createRowsFor: eachObject in: registeredObjectsRowMap].
    rowMap := registeredObjectsRowMap differenceFrom: mementoObjectsRowMap.
    deletedObjects 
    	do: [:eachObject | session createDeleteRowsFor: eachObject in: rowMap]!

isNewObject: each 
    ^self newObjects includes: each.!

mementoObjects
    "Warning: Excessive cleverness!!! The mementoObjects we want to iterate over are the values in the correspondenceMap dictionary. We were getting the values and returning them, but if all we need to do is iterate, then the dictionary itself works fine"
    ^self correspondenceMap.!

postCommit
    self sendPostWriteNotification.
    self updateSessionCache.
    commitInProgress := false.!

preCommit
    self registerTransitiveClosure.
    commitInProgress := true.
    self createRows.
    self validateRows.
    self buildCommitPlan.
    self sendPreWriteNotification!

registeredObjects
    ^self correspondenceMap keys!

registerTransitiveClosure
    "Look for new objects reachable from currently registered objects"

    self 
    	registeredObjectsDo: [:eachObject | self registerTransitiveClosureFrom: eachObject]!

rollback
    self abort.!

validateRows
    "Perform basic validation. Right now, just test for equal named but non-identical tables, a sign of a malformed  system or other loss of identity"
    
    | tables tableNames |
    tables := Set new.
    rowMap rowsDo: [:each |
    	tables add: each table].
    tableNames := tables collect: [:each | each qualifiedName].
    tables asSet size = tableNames asSet size ifFalse: [self error: 'multiple table objects with the same name'].! !

!UnitOfWork methodsFor: 'private'!

privateGetRowMap
    ^rowMap!

privateGetTransaction
    ^transaction.!

registerAsNew: anObject 
    anObject isNil ifTrue: [^nil].
    commitInProgress ifTrue: [self halt]. "Should not happen. Probably indicates that we're triggering proxies during the commit process"
    self newObjects add: anObject.
    self register: anObject.
    ^anObject!

sendPostWriteNotification
    self 
    	registeredObjectsDo: [:eachObject | session sendPostWriteEventTo: eachObject]!

sendPreWriteNotification
    self 
    	registeredObjectsDo: [:eachObject | session sendPreWriteEventTo: eachObject]! !

!UnitOfWork methodsFor: 'accessing'!

correspondenceMap
    ^transaction undoMap!

newObjects
    newObjects isNil ifTrue: [newObjects := IdentitySet new].
    ^newObjects!

numberOfRows
    ^commitPlan size + deletePlan size.!

session
    "Private - Answer the value of the receiver's ''session'' instance variable."

    ^session!

session: anObject
    "Private - Set the value of the receiver's ''session'' instance variable to the argument, anObject."

    session := anObject! !

!UnitOfWork methodsFor: 'deletion'!

delete: anObject 
    deletedObjects add: anObject!

hasPendingDeletions
    ^deletedObjects isEmpty not.!

willDelete: anObject
    ^deletedObjects includes: anObject.! !

!UnitOfWork methodsFor: 'private/mapping'!

addObject: eachObject toCacheKeyedBy: key 
    
    self session cacheAt: key put: eachObject.!

addToCommitPlan: aRow
    
    commitPlan add: aRow.!

addToDeletePlan: aRow
    
    deletePlan add: aRow.!

buildCommitPlan
    | tablesInCommitOrder |
    commitPlan := OrderedCollection new.
    deletePlan := OrderedCollection new.
    tablesInCommitOrder := session tablesInCommitOrder.
    tablesInCommitOrder do: 
    		[:eachTable | 
    		self rowsForTable: eachTable
    			do: 
    				[:eachRow | 
    				eachRow forDeletion 
    					ifTrue: [self addToDeletePlan: eachRow]
    					ifFalse: [self addToCommitPlan: eachRow]]]!

checkIfInstantiationRequiredFor: anObject mapping: eachMapping
    "Sometimes we have to instantiate the targets if they weren't. Specifically, if there's a relationship where the target has a foreign key to us. e.g. if X has a 1-many to Y, and we don't instantiate the collection of Y, but then replace it with some other collection. The Y's keys have to be updated, so we need to make sure they're read"

    | original targetObject mapping |
    mapping := eachMapping applicableMappingForObject: anObject.
    mapping isRelationship ifFalse: [^false].
    original := self originalValueFor: anObject mapping: mapping.
    targetObject := mapping getValueFrom: anObject.
    original == targetObject ifTrue: [^false].
    original class == Proxy ifFalse: [^false].
    original isInstantiated ifTrue: [^false].
    original yourself.
    ^true.!

originalValueFor: anObject mapping: eachMapping
    | memento |
    memento := transaction undoMap at: anObject.
    ^eachMapping getValueFrom: memento.!

readBackNewRowInformation
    | changedObjects |
    changedObjects := rowMap objects.
    changedObjects
    	do: 
    		[:each | 
    		| descriptor |
    		descriptor := session descriptorFor: each class.
    		descriptor isNil ifFalse: [descriptor readBackNewRowInformationFor: each in: rowMap]]!

registerTransitiveClosureFrom: anObject
    | descriptor |
    anObject glorpIsCollection ifTrue: [
    	anObject do: [:each | session register: each].
    	^self].

    descriptor := session descriptorFor: anObject class.
    descriptor isNil ifTrue: [^self].
    descriptor mappings do: [:eachMapping |
    		self checkIfInstantiationRequiredFor: anObject mapping: eachMapping].
    descriptor referencedIndependentObjectsFrom: anObject do: [:eachObject |
    	session register: eachObject].!

updateSessionCache
    rowMap
    	keysAndValuesDo: [:eachObject :eachRow | 
    		eachRow shouldBeWritten ifTrue: [
    			self updateSessionCacheFor: eachObject withRow: eachRow]].
    deletedObjects do: [:each |
    	session cacheRemoveObject: each].!

updateSessionCacheFor: anObject withRow: aRow 
    | key |
    anObject class == RowMapKey ifTrue: [^self].  "Not cachable"
    key := aRow primaryKey.
    (session cacheContainsObjectForClass: anObject class key: key) 
    	ifFalse: [self addObject: anObject toCacheKeyedBy: key].!

writeRows
    commitPlan do: [:eachRow |
    	session writeRow: eachRow].
    deletePlan reverseDo: [:eachRow |
    	session writeRow: eachRow].
    self readBackNewRowInformation.! !

!UnitOfWork methodsFor: 'registering'!

isRegistered: anObject
    ^transaction isRegistered: anObject.!

register: anObject 
    | realObject |
    commitInProgress ifTrue: [self halt]. "Should not happen. Probably indicates that we're triggering proxies during the commit process"
    realObject := transaction register: anObject.
    self registerTransitiveClosureFrom: realObject.! !

!UnitOfWork methodsFor: 'enumerating'!

registeredObjectsDo: aBlock
    transaction registeredObjectsDo: [:each |
    	(each glorpIsCollection or: [session hasDescriptorFor: each]) ifTrue: [
    		aBlock value: each]].!

rowsForTable: aTable do: aBlock
    rowMap rowsForTable: aTable do: aBlock.! !

!UnitOfWork methodsFor: 'initializing'!

initialize
    transaction := ObjectTransaction new.
    self reinitialize!

reinitialize
    rowMap := RowMap new.
    commitInProgress := false.
    deletedObjects := IdentitySet new.
    transaction abort.! !

!UnitOfWork class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!UnitOfWork class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ForeignKeyConstraint methodsFor: 'initializing'!

sourceField: aDatabaseField targetField: anotherDatabaseField
    self
    	sourceField: aDatabaseField
    	targetField: anotherDatabaseField
    	suffixExpression: nil.!

sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpressionString
    self
    	sourceField: aDatabaseField;
    	targetField: anotherDatabaseField;
    	suffixExpression: suffixExpressionString.! !

!ForeignKeyConstraint methodsFor: 'accessing'!

name
    name isNil ifTrue: [name := self generateName].
    ^name.!

name: aString
    name := aString.!

sourceField
    ^sourceField!

sourceField: anObject
    sourceField := anObject.!

suffixExpression
    ^suffixExpression!

suffixExpression: anObject
    suffixExpression := anObject.!

targetField
    ^targetField!

targetField: anObject
    targetField := anObject.! !

!ForeignKeyConstraint methodsFor: 'printing'!

creationString
    | ws |
    ws := WriteStream on: (String new: 50).
    ws
    	nextPutAll: 'CONSTRAINT ';
    	nextPutAll: self name;
    	nextPutAll: ' FOREIGN KEY (';
    	nextPutAll: sourceField name;
    	nextPutAll: ') REFERENCES ';
    	nextPutAll: targetField asConstraintReferenceString.
    self suffixExpression isNil
    	ifFalse:
    		[ws
    			space;
    			nextPutAll: self suffixExpression].
    ^ws contents.!

dropString
    | ws |
    ws := WriteStream on: (String new: 50).
    ^ws
    	nextPutAll: 'ALTER TABLE ';
    	nextPutAll: sourceField table sqlString;
    	nextPutAll: ' DROP CONSTRAINT ';
    	nextPutAll: self name;
    	contents.!

generateName
    | stream |
    stream := WriteStream on: (String new: 100).
    sourceField printForConstraintNameOn: stream maxLength: 10.
    stream nextPutAll: '_TO_'.
    targetField printForConstraintNameOn: stream maxLength: 10.
    stream nextPutAll: '_REF'.
    ^stream contents.!

printOn: aStream
    super printOn: aStream.
    aStream
    	nextPut: $(;
    	nextPutAll: self name;
    	nextPut: $).! !

!ForeignKeyConstraint class methodsFor: 'instance creation'!

sourceField: aDatabaseField targetField: anotherDatabaseField
    ^self
    	sourceField: aDatabaseField
    	targetField: anotherDatabaseField
    	suffixExpression: nil.!

sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpression
    ^(self new)
    	sourceField: aDatabaseField targetField: anotherDatabaseField suffixExpression: suffixExpression;
    	yourself.! !

!ForeignKeyConstraint class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!VarCharType methodsFor: 'accessing'!

typeString
    ^self typeName, '(', width printString, ')'.! !

!VarCharType methodsFor: 'private'!

typeName
    ^typeName.!

typeName: aString
    typeName := aString.! !

!VarCharType methodsFor: 'initialize'!














initialize
    super initialize.
    typeName := 'varchar'.! !

!VarCharType methodsFor: 'testing'!

isVariableWidth
    "Return true if this type allows varying length data within a particular instance. e.g., this is true for a varchar, but false for a fixed size character field"
    ^true.! !

!VarCharType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ObjectBuilder methodsFor: 'selecting fields'!

fieldsForSelectStatement
    ^self fieldsFromThePerspectiveOfTheMainSelect: (self fieldsFromMyPerspective).!

fieldsFromMyPerspective
    ^query returnProxies 
    	ifTrue: [self descriptor table primaryKeyFields]
    	ifFalse: [self descriptor fieldsForSelectStatement]!

fieldsFromThePerspectiveOfTheMainSelect: aCollection
    ^expression translateFields: aCollection.! !

!ObjectBuilder methodsFor: 'building objects'!

buildObjectFrom: anArray
    self row: anArray.
    self requiresPopulating ifTrue: [self populateInstance].
    self session markAsCurrentOfClass: instance class key: self key.!

buildProxy
    | parameters |
    parameters := IdentityDictionary new.
    self descriptor primaryTable primaryKeyFields
    	do:
    		[:eachField | parameters at: eachField put: (self valueOfField: eachField)].
    instance := (self newProxy)
    	session: self session;
    	parameters: parameters.
    ^self.!

canBuild
    "If we have a regular object with a nil primary key, or if we have an embedded object whose values are all nil, we can't build anything (probably due to an outer join)"
    ^self descriptor mapsPrimaryKeys
    	ifTrue: [self key notNil]
    	ifFalse: [true].!

canCache
    ^self descriptor mapsPrimaryKeys!

findInstanceForRow: aRow useProxy: useProxies
    instance := nil.
    self row: aRow.
    self canBuild ifFalse: [^self].
    self lookupCachedObject.
    instance isNil
    	ifFalse:
    		[requiresPopulating := requiresPopulating | query shouldRefresh.
    		^self].
    useProxies
    	ifTrue: [self buildProxy]
    	ifFalse:
    		[requiresPopulating := true.
    		instance := (expression descriptor
    			describedConcreteClassFor: self row
    			withBuilder: self) basicNew.
    		self canCache ifTrue: [self session cacheAt: self key put: instance]].!

knitResultIn: aSimpleQuery
    "Connect up our built object with any other objects that reference it. Used if we retrieve more than one thing in the same query"

    | relatedBuilder |
    expression canKnit ifFalse: [^self].
    relatedBuilder := aSimpleQuery elementBuilderFor: expression base.
    relatedBuilder isNil ifFalse: [
    	expression mapping knit: relatedBuilder instance to: self instance in: self].!

lookupCachedObject
    | resultClass |
    self canBuild ifFalse: [^self].
    self canCache
    	ifTrue:
    		[
    		resultClass := expression descriptor describedClass.
    		(self session hasExpired: resultClass key: self key)
    			ifTrue:
    				[instance := self session expiredInstanceOf: resultClass key: self key.
    				requiresPopulating := true.
    				isExpired := true]
    			ifFalse:
    				[instance := self session cacheLookupForClass: resultClass key: self key.
    				requiresPopulating := instance isNil]].!

newProxy
    "Create a proxy with a primary key query in which the parameters are the primary key fields"
    | whereExpression |
    whereExpression := Join new.
    self descriptor primaryTable primaryKeyFields do: [:eachField | 
    	whereExpression addSource: eachField target: eachField].
    ^Proxy 
    	returningOneOf: query resultClass 
    	where: whereExpression
    	in: self session.!

populateInstance
    key isNil ifTrue: [^self].
    (self system descriptorFor: instance) populateObject: instance inBuilder: self.! !

!ObjectBuilder methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPut: $(.
    expression printOn: aStream.
    aStream nextPut: $).! !

!ObjectBuilder methodsFor: 'accessing'!

canCauseDuplicateRows
    ^expression class == MappingExpression and: [expression mapping isToManyRelationship].!

descriptor
    
    ^expression descriptor.!

instance: anObject
    instance := anObject!

key
    ^self primaryKey.!

primaryKey
    "We use self as a special guard value to indicate that the value hasn't changed"
    key == self ifFalse: [^key].
    self canCache ifFalse: [^nil].
    key := self descriptor table primaryKeyFields
    	collect: [:each | self valueOfField: each].
    key size = 1 ifTrue: [key := key first].
    ^key.!

requiresPopulating
    ^requiresPopulating and: [self returnProxies not].!

requiresPopulating: aBoolean
    requiresPopulating := aBoolean!

returnProxies
    ^query returnProxies.! !

!ObjectBuilder methodsFor: 'initializing'!

initialize
    requiresPopulating := false.
    isExpired := false.! !

!ObjectBuilder class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TextType methodsFor: 'initialize'!

initialize
    super initialize.
    typeString := 'text'.! !

!TextType methodsFor: 'testing'!

isVariableWidth
    ^true.! !

!TextType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FixedSizeQueue methodsFor: 'api'!

add: anObject
    items add: anObject.
    items size > maximumSize ifTrue: [items removeFirst].! !

!FixedSizeQueue methodsFor: 'accessing'!

maximumSize
    ^maximumSize!

maximumSize: anInteger
    maximumSize := anInteger.
    items := OrderedCollection new: maximumSize + 1.! !

!FixedSizeQueue methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '('.
    aStream nextPutAll: items size printString.
    aStream nextPut: $/.
    aStream nextPutAll: maximumSize printString.
    aStream nextPutAll: ')'.! !

!FixedSizeQueue class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FixedSizeQueue class methodsFor: 'instance creation'!

maximumSize: anInteger
    ^self basicNew maximumSize: anInteger.!

new
    self error: 'must supply a size'.!

new: anInteger
    ^self maximumSize: anInteger.! !

!Proxy methodsFor: 'testing'!

isInstantiated
    ^isInstantiated.! !

!Proxy methodsFor: 'accessing'!

class
    ^Proxy.!

parameters
    ^parameters!

parameters: aDictionary
    parameters := aDictionary.!

query
    ^query!

query: aQuery 
    query := aQuery!

session
    ^session!

session: aSession 
    session := aSession! !

!Proxy methodsFor: 'initialize'!

doesNotUnderstand: aMessage
    ^self getValue perform: aMessage selector withArguments: aMessage arguments.!

initialize
    isInstantiated := false.! !

!Proxy methodsFor: 'notification'!

glorpPostFetch: aSession! !

!Proxy methodsFor: 'api'!

getValue
    isInstantiated ifTrue: [^value].
    parameters isNil ifTrue: [parameters := Dictionary new: 0].
    [value := query executeWithParameters: parameters in: session] 
    	ensure: [isInstantiated := true].
    ^value.! !

!Proxy methodsFor: 'printing'!

printOn: aStream 
    aStream nextPut: ${.
    isInstantiated 
    	ifTrue: [self getValue printOn: aStream]
    	ifFalse: 
    		[aStream nextPutAll: 'uninstantiated '.
    		query readsOneObject ifFalse: [aStream nextPutAll: 'collection of '].
    		query resultClass printOn: aStream].
    aStream nextPut: $}!

printString
    | aStream |
    aStream := WriteStream on: (String new: 16).
    self printOn: aStream.
    ^aStream contents! !

!Proxy class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Proxy class methodsFor: 'instance creation'!

new
    ^super new initialize.!

returningManyOf: aClass where: aBlock 
    ^self new query: (Query returningManyOf: aClass where: aBlock)!

returningManyOf: aClass where: aBlock in: aSession
    
    ^self new 
    	query: (Query returningManyOf: aClass where: aBlock);
    	session: aSession!

returningOneOf: aClass where: aBlock 
    ^self new query: (Query returningOneOf: aClass where: aBlock)!

returningOneOf: aClass where: aBlock in: aSession
    
    ^self new 
    	query: (Query returningOneOf: aClass where: aBlock);
    	session: aSession.! !

!EmptyExpression methodsFor: 'iterating'!

do: aBlock skipping: aSet
    "Iterate over the expression tree"

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    base do: aBlock skipping: aSet.
    aBlock value: self.!

rebuildOn: aBaseExpression 
    | copy |
    copy := self copy.
    copy base: aBaseExpression.
    ^copy.! !

!EmptyExpression methodsFor: 'api'!

AND: anExpression
    anExpression isNil ifTrue: [^self].
    ^anExpression!

OR: anExpression
    anExpression isNil ifTrue: [^self].
    ^anExpression! !

!EmptyExpression methodsFor: 'accessing'!

base
    ^base.!

base: aBaseExpression
    base := aBaseExpression.!

isFalse
    ^value not!

isTrue
    ^value!

value: aValue
    "a value is expected to be nil, true, or false. we treat nil as true"
    value := aValue isNil ifTrue: [true] ifFalse: [aValue].! !

!EmptyExpression methodsFor: 'navigating'!

ultimateBaseExpression
    base isNil ifTrue: [base := BaseExpression new].
    ^base.! !

!EmptyExpression methodsFor: 'testing'!

canHaveBase
    ^true.!

isEmptyExpression
    ^true.! !

!EmptyExpression methodsFor: 'As yet unclassified'!

printSQLOn: aCommand withParameters: aDictionary
    ^self.! !

!EmptyExpression methodsFor: 'printing'!

printTreeOn: aStream 
    aStream nextPutAll: 'empty expression'.! !

!EmptyExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!EmptyExpression class methodsFor: 'instance creation'!

on: aValue
    ^self new value: aValue.! !

!AdHocMapping methodsFor: 'mapping'!

field
    | fields |
    fields := self mappedFields.
    fields size = 1 ifFalse: [self error: 'This mapping does not correspond to exactly one field'].
    ^fields first.!

mappedFields
    ^mappedFields.!

mappedTables
    ^(self mappedFields collect: [:each | each table]) asSet.!

referencedIndependentObjectsFrom: anObject
    "Assumes that the only object this might affect is our primary attribute. That's probably valid. I think."
    | object otherDescriptor |
    object := self getValueFrom: anObject.
    otherDescriptor := self system descriptorFor: object.
    ^otherDescriptor isNil ifTrue: [#()] ifFalse: [Array with: object].!

trace: aTracing context: anExpression
    ^self.! !

!AdHocMapping methodsFor: 'initialize/release'!

setAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection
 
    self attributeName: aSymbol.
    fromDbMappingBlock := fromBlock.
    toDbMappingBlock := toBlock.
    mappedFields := aFieldCollection.! !

!AdHocMapping methodsFor: 'testing'!

controlsTables
    ^false!

hasImpliedClauses
    "We may imply more than one clause, or a clause which is different from the one directly implied by the relationship"
    ^true!

isRelationship
    "True when the mapping associates different persistent classes."

    ^false!

isStoredInSameTable
    ^true.! !

!AdHocMapping methodsFor: 'printing SQL'!

allRelationsFor: rootExpression
    "We may have multiple relationships."
    | tables rows result |
    tables := self mappedTables.
    rows := Dictionary new.
    tables do: [:each | rows at: each put: (DatabaseRow newForTable: each)].
    toDbMappingBlock value: rows value: rootExpression rightChild value.  "Assuming this is a constant"
    result := nil.
    rows do: [:eachRow |
    	| table |
    	table := rootExpression leftChild base getTable: eachRow table.
    	eachRow fieldsAndValidValuesDo: [:eachField :eachValue |  | newExp |
    		newExp := (table getField: eachField) get: rootExpression relation withArguments: (Array with: eachValue).
    		result := newExp AND: result.]].
    ^result.!

convertedDbValueOf: anObject
    | tables rows |
    tables := self mappedTables.
    rows := Dictionary new.
    tables do: [:each | rows at: each put: (DatabaseRow newForTable: each)].
    toDbMappingBlock value: rows value: anObject.
    rows keysAndValuesDo: [:eachTable :eachRow |
    	^eachRow at: mappedFields first].! !

!AdHocMapping methodsFor: 'public'!

mapFromObject: anObject intoRowsIn: aRowMap
    | value rows |
    readOnly ifTrue: [^self].
    value := self getValueFrom: anObject.
    rows := Dictionary new.
    descriptor tables do: [:each |
    	rows at: each put: (aRowMap findOrAddRowForTable: each withKey: anObject)].
    toDbMappingBlock value: rows value: value.!

mapObject: anObject inElementBuilder: anElementBuilder
    self
    	setValueIn: anObject
    	to:
    		(fromDbMappingBlock
    			value: anElementBuilder row
    			value: anElementBuilder
    			value: BaseExpression new).! !

!AdHocMapping methodsFor: 'As yet unclassified'!

valueIn: anElementBuilder withFieldContextFrom: anExpression
    ^fromDbMappingBlock
    	value: anElementBuilder row
    	value: anElementBuilder
    	value: anExpression.! !

!AdHocMapping class methodsFor: 'instance creation'!

forAttribute: aSymbol fromDb: fromBlock toDb: toBlock mappingFields: aFieldCollection 
    ^super new 
    	setAttribute: aSymbol
    	fromDb: fromBlock
    	toDb: toBlock
    	mappingFields: aFieldCollection! !

!AdHocMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AddingWriteStream methodsFor: 'accessing'!

contents
    ^target.!

nextPut: anObject
    target add: anObject.!

on: aSet
    target := aSet.!

target
    ^target!

target: aCollection
    target := aCollection! !

!ConstantMapping methodsFor: 'accessing'!

constantValue
    ^constantValue.!

constantValue: anObject
    constantValue := anObject.!

constantValueIn: aSession
    ^valueIsSession
    	ifTrue: [aSession]
    	ifFalse: [constantValue].!

constantValueIsSession
    valueIsSession := true.!

mappedFields
    "Return a collection of fields that this mapping will write into any of the containing object's rows"

    ^#().! !

!ConstantMapping methodsFor: 'initialize/release'!

initialize
    super initialize.
    valueIsSession := false.! !

!ConstantMapping methodsFor: 'api'!

getValueFrom: anObject
    ^constantValue.! !

!ConstantMapping methodsFor: 'mapping'!

mapFromObject: anObject intoRowsIn: aRowMap!
mapObject: anObject inElementBuilder: anElementBuilder
    | value |
    value := anElementBuilder isNil
    	ifTrue: [constantValue]
    	ifFalse: [self constantValueIn: anElementBuilder session].
    self setValueIn: anObject to: value.!

referencedIndependentObjectsFrom: anObject
    ^#().!

trace: aTracing context: anExpression
    ^self.! !

!ConstantMapping methodsFor: 'testing'!

controlsTables
    "Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

    ^false!

isRelationship
    ^false! !

!ConstantMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DirectMapping methodsFor: 'mapping'!

convertValueToDatabaseForm: aValue
    
    converter isNil ifTrue: [^aValue].
    ^converter convertedDbValueOf: aValue.!

expressionFor: anObject
    "Return our expression using the object's values. e.g. if this was a direct mapping from id->ID and the object had id: 3, then return TABLE.ID=3"

    | value |
    value := attributeAccessor getValueFrom: anObject. 
    ^(BaseExpression new getField: field) get: #= withArguments: (Array with: value).!

mapFromObject: anObject intoRowsIn: aRowMap
    | dbValue value row |
    readOnly ifTrue: [^self].
    value := self getValueFrom: anObject.
    dbValue := self convertedDbValueOf: value.
    row := aRowMap findOrAddRowForTable: self field table withKey: anObject.
    row at: field put: dbValue.!

mapObject: anObject inElementBuilder: anElementBuilder
    | value |
    value := self valueInBuilder: anElementBuilder.
    self setValueIn: anObject to: value.!

readBackNewRowInformationFor: anObject fromRowsIn: aRowMap 
    | value row |
    field isGenerated ifFalse: [^self].
    row := aRowMap findOrAddRowForTable: self field table withKey: anObject.
    value := self convertedStValueOf: (row at: field ifAbsent: [^self]).
    attributeAccessor setValueIn: anObject to: value!

trace: aTracing context: anExpression
    ^self.!

valueIn: anElementBuilder withFieldContextFrom: anExpression
    | dbValue |
    dbValue := anElementBuilder
    	valueOfField: (anExpression translateField: field).
    ^self convertedStValueOf: dbValue.!

valueInBuilder: anElementBuilder
    | dbValue |
    dbValue := anElementBuilder valueOfField: field.
    ^self convertedStValueOf: dbValue.! !

!DirectMapping methodsFor: 'printing SQL'!

printSQLOn: aStream withParameters: aDictionary
    self field printSQLOn: aStream withParameters:aDictionary.! !

!DirectMapping methodsFor: 'private'!

convertedDbValueOf: stValue 
    ^converter isNil
    	ifTrue: [stValue]
    	ifFalse: [converter convert: stValue toDatabaseRepresentationAs: self field type]!

convertedStValueOf: dbValue 
    ^(converter isNil)
    	ifTrue: [dbValue]
    	ifFalse: [converter convert: dbValue fromDatabaseRepresentationAs: self field type]! !

!DirectMapping methodsFor: 'initialize-release'!

setConverterBetween: aClass and: aDbField
    aClass isNil ifTrue: [^self].
    converter := field converterForStType: aClass! !

!DirectMapping methodsFor: 'testing'!

controlsTables
    "Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

    ^false!

isRelationship
    "True when the mapping associates different persistent classes."

    ^false!

isStoredInSameTable
    ^true!

mappedFields
    "Return a collection of fields that this mapping will write into any of the containing object's rows"

    ^Array with: self field! !

!DirectMapping methodsFor: 'enumerating'!

referencedIndependentObjectsFrom: anObject
    ^#().! !

!DirectMapping methodsFor: 'accessing'!

converter
    ^converter.!

converter: aDatabaseConverter
    converter := aDatabaseConverter.!

field
    "Private - Answer the value of the receiver's ''field'' instance variable."

    ^field!

field: anObject
    "Private - Set the value of the receiver's ''field'' instance variable to the argument, anObject."

    field := anObject.! !

!DirectMapping class methodsFor: 'instance creation'!

from: attributeName to: field
    ^self from: attributeName
    	type: field impliedSmalltalkType
    	to: field!

from: attributeName type: aClass to: field
    ^self new
    	attributeName: attributeName;
    	field: field;
    	setConverterBetween: aClass and: field! !

!DirectMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseCommand methodsFor: 'accessing'!

bindings
    self subclassResponsibility.!

blockFactor
    ^5  "A reasonable default if we don't know"!

parameterFields
    self subclassResponsibility!

parameterTypeSignature
    self subclassResponsibility.!

platform
    ^platform!

platform: aDatabasePlatform
    platform := aDatabasePlatform.!

signature
    ^self sqlString, self parameterTypeSignature.!

sqlString
    sqlString isNil ifTrue: [
    	stream := WriteStream on: (String new: 100).
    	self printSQL.
    	sqlString := stream contents.
    	stream := nil].
    ^sqlString.!

useBinding
    ^useBinding!

useBinding: aBoolean
    useBinding := aBoolean! !

!DatabaseCommand methodsFor: 'stream behaviour'!

nl
    stream nl.!

nextPut: aCharacter
    stream nextPut: aCharacter.!

nextPutAll: aString
    stream nextPutAll: aString.!

space
    stream space.! !

!DatabaseCommand methodsFor: 'executing'!

printSQL
    self subclassResponsibility.! !

!DatabaseCommand methodsFor: 'initializing'!

initialize! !

!DatabaseCommand methodsFor: 'testing'!

canBind: aValue to: aType
    useBinding ifFalse: [^false].
    ^self platform canBind: aValue to: aType.! !

!DatabaseCommand class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseCommand class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!SelectCommand methodsFor: 'accessing'!

bindings
    boundExpressions isNil ifTrue: [^#()].
    ^boundExpressions collect: [:each | each bindingIn: self]!

blockFactor
    blockFactor isNil ifTrue: [blockFactor := query expectedRows].
    ^blockFactor.!

findBoundExpressions
    self useBinding ifFalse: [^nil].
    boundExpressions := OrderedCollection new.
    query joins, (Array with: query criteria) do: [:eachBigExpression |
    	boundExpressions addAll: (eachBigExpression select: [:eachIndividualExpressionNode | eachIndividualExpressionNode hasBindableExpressionsIn: self])].!

parameters
    ^parameters!

parameters: aDictionary
    parameters := aDictionary!

parameterTypeSignature
    | result |
    result := WriteStream on: String new.
    parameters do: [:each | result nextPutAll: each class name].
    ^result contents.!

printSQL
    stream nextPutAll: 'SELECT '.
    query printSelectFieldsOn: self.
    self findBoundExpressions.
    query printTablesOn: self.
    query printCriteriaOn: self.
    query printJoinsOn: self.
    query printOrderingOn: self.!

query
    ^query!

query: aQuery
    query := aQuery! !

!SelectCommand methodsFor: 'testing'!

canBind: aValue to: aType
    aValue isNil ifTrue: [^false].
    ^super canBind: aValue to: aType.! !

!SelectCommand class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!SelectCommand class methodsFor: 'instance creation'!

forQuery: aQuery parameters: aDictionary
    ^(self new)
    	query: aQuery;
    	parameters: aDictionary;
    	yourself.!

forQuery: aQuery parameters: aDictionary useBinding: aBoolean platform: aDatabasePlatform
    ^(self new)
    	query: aQuery;
    	parameters: aDictionary;
    	useBinding: aBoolean;
    	platform: aDatabasePlatform;
    	yourself.! !

!RowBasedCommand methodsFor: 'accessing'!

bindings
    | bound |
    bound := OrderedCollection new.
    self parameterFields do: [:each | 
    	(self canBind: (row at: each) to: each type) ifTrue: [bound add: (row at: each)]].
    ^bound asArray.!

parameterTypeSignature
    | result |
    result := WriteStream on: String new.
    row keysAndValuesDo: [:eachKey :eachValue | result nextPutAll: eachValue class name].
    ^result contents.!

row
    ^row.!

row: anObject
    row := anObject.! !

!RowBasedCommand class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!RowBasedCommand class methodsFor: 'instance creation'!

forRow: aDatabaseRow useBinding: aBoolean platform: aDatabasePlatform
    ^(self new)
    	row: aDatabaseRow;
    	useBinding: aBoolean;
    	platform: aDatabasePlatform;
    	yourself.! !

!DeleteCommand methodsFor: 'accessing'!

blockFactor
    ^1.!

parameterFields
    | fields |
    fields := row table primaryKeyFields.
    fields isEmpty ifTrue: [fields := row fields].
    ^fields asArray!

printSQL
    self nextPutAll: 'DELETE FROM '.
    row table printSQLOn: self withParameters: #().
    self nextPutAll: ' WHERE '.
    row printPrimaryKeyTemplateOn: self.! !

!DeleteCommand class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!UpdateCommand methodsFor: 'accessing'!

blockFactor
    ^1.!

parameterFields
    ^row nonPrimaryKeyFields asArray , row table primaryKeyFields asArray!

printSQL
    self nextPutAll: 'UPDATE '.
    row table printSQLOn: self withParameters: #().
    self nextPutAll: ' SET '.
    GlorpHelper 
    	do: [:field | row printEqualityTemplateForField: field on: self]
    	for: row nonPrimaryKeyFields
    	separatedBy: [self nextPut: $,].
    self nextPutAll: ' WHERE '.
    row printPrimaryKeyTemplateOn: self.! !

!UpdateCommand class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!InsertCommand methodsFor: 'accessing'!

parameterFields
    | unsortedFields |
    unsortedFields := row nonGeneratedFieldsWithValues.
    ^row table fields select: [:each | unsortedFields includes: each]!

printSQL
    | fields |
    self nextPutAll: 'INSERT INTO '.
    row table printSQLOn: self withParameters: #().
    fields := row nonGeneratedFieldsWithValues.
    self nextPutAll: ' ('.
    GlorpHelper
    	do: [:each | self nextPutAll: (platform nameForColumn: each name)]
    	for: fields
    	separatedBy: [self nextPutAll: ','].
    self nextPutAll: ') '.
    self nextPutAll: ' VALUES ('.
    GlorpHelper
    	do:
    		[:each | 
    		(self canBind: (row at: each) to: each type)
    			ifTrue: [self nextPut: $?]
    			ifFalse: [row printValueOfField: each on: self]]
    	for: fields
    	separatedBy: [self nextPutAll: ','].
    self nextPutAll: ')'.! !

!InsertCommand class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!DatabaseSequence methodsFor: 'sequencing'!

creationString
    ^'Creation string unspecified for this type of sequence'.!

postWriteAssignSequenceValueFor: aField in: aRow
    self subclassResponsibility.!

postWriteAssignSequenceValueFor: aField in: aRow using: aSession
    self subclassResponsibility.!

preWriteAssignSequenceValueFor: aField in: aRow
    self subclassResponsibility.!

preWriteAssignSequenceValueFor: aField in: aRow using: aSession 
    self subclassResponsibility.! !

!DatabaseSequence methodsFor: 'initialize/release'!

initialize! !

!DatabaseSequence class methodsFor: 'instance creation'!

named: aString
    ^self new name: aString.!

new
    ^super new initialize.! !

!DatabaseSequence class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!NamedSequence methodsFor: 'accessing'!

name
    ^name.!

name: aString
    name := aString.! !

!NamedSequence class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!TableBasedSequence methodsFor: 'accessing'!

sequenceTableName
    "Private - Answer the value of the receiver's ''sequenceTableName'' instance variable."

    ^sequenceTableName!

sequenceTableName: aString
    sequenceTableName := aString! !

!TableBasedSequence class methodsFor: 'defaults'!

default
    ^self new sequenceTableName: 'SEQUENCE'.! !

!TableBasedSequence class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!SQLServerSequence methodsFor: 'sequencing'!

postWriteAssignSequenceValueFor: aDatabaseField in: aDatabaseRow using: aSession 
    aDatabaseRow at: aDatabaseField
    	put: ((aSession accessor 
    			executeSQLString: 'SELECT @@IDENTITY') first atIndex: 1).!

preWriteAssignSequenceValueFor: aField in: aRow using: aSession! !

!SQLServerSequence class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!JustSelectTheMaximumSequenceValueAndAddOne methodsFor: 'other'!

postWriteAssignSequenceValueFor: aField in: aRow using: aSession
    self subclassResponsibility.!

preWriteAssignSequenceValueFor: aField in: aRow using: aSession
    | stream rows value |
    "I repeat: ick"
    stream := WriteStream on: (String new: 50).
    stream nextPutAll: 'SELECT MAX('.
    aField printSQLOn: stream withParameters: #().
    stream nextPutAll: ') FROM '.
    aRow table printSQLOn: stream withParameters: #().
    rows := aSession accessor executeSQLString: stream contents.
    value := rows first first isNil ifTrue: [1] ifFalse: [rows first first + 1].
    aRow at: aField put: value.! !

!JustSelectTheMaximumSequenceValueAndAddOne class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!NullSequence methodsFor: 'sequencing'!

postWriteAssignSequenceValueFor: aField in: aRow!
postWriteAssignSequenceValueFor: aField in: aRow using: aSession!
preWriteAssignSequenceValueFor: aField in: aRow! !

!NullSequence methodsFor: 'public'!

preWriteAssignSequenceValueFor: aField in: aRow using: aSession! !

!NullSequence class methodsFor: 'defaults'!

default
    ^self new.! !

!NullSequence class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!NullSequence class methodsFor: 'instance creation'!

new
    Singleton isNil ifTrue: [Singleton := self basicNew].
    ^Singleton.! !

!InMemorySequence methodsFor: 'public'!

preWriteAssignSequenceValueFor: aField in: aRow using: aSession
    aRow at: aField put: (count := count + 1).! !

!InMemorySequence methodsFor: 'sequencing'!

postWriteAssignSequenceValueFor: aField in: aRow!
postWriteAssignSequenceValueFor: aField in: aRow using: aSession!
preWriteAssignSequenceValueFor: aField in: aRow
    aRow at: aField put: (count := count + 1).! !

!InMemorySequence methodsFor: 'initialize/release'!

initialize
    super initialize.
    count := 0.! !

!InMemorySequence class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!InMemorySequence class methodsFor: 'defaults'!

default
    ^self new.! !

!Cache methodsFor: 'private'!

basicAt: anObject ifAbsent: aBlock
    ^items at: anObject ifAbsent: aBlock.!

do: aBlock
    items do: aBlock.!

expiredInstanceFor: key
    "Return the expired instance. Used for refreshing so that we don't recursively try and refresh when we get the instance to be refreshed"
    | item value |
    item := self basicAt: key ifAbsent: [self error: 'No expired instance found'].
    value := policy contentsOf: item.
    (self hasItemExpired: item) ifFalse: [self error: 'No expired instance found'].
    ^value.!

markAsCurrentAtKey: key
    | item |
    item := self basicAt: key ifAbsent: [^false].
    ^policy markEntryAsCurrent: item in: self.!

markEntryAsCurrent: anItem
    "The policy has told us to mark an item as current. This is only really useful for weak policies, which tell us to keep an additional pointer to the object in a (presumably) fixed-size collection"
    extraReferences isNil ifFalse: [extraReferences add: anItem].! !

!Cache methodsFor: 'lookup'!

at: key ifAbsent: aBlock 
    | item value |
    item := self basicAt: key ifAbsent: [^aBlock value].
    value := policy contentsOf: item.
    (self hasItemExpired: item) 
    	ifTrue: 
    		[policy takeExpiryActionForKey: key withValue: value in: self. 
    		(items includesKey: key) ifFalse: [^aBlock value]].
    ^value.!

at: key ifAbsentPut: aBlock 
    | item |
    item := self at: key ifAbsent: [nil].
    ^item isNil 
    	ifTrue: [ | newItem|
    		newItem := policy cacheEntryFor: aBlock value.
    		self markEntryAsCurrent: newItem.
    		items at: key put: newItem]
    	ifFalse: [self markEntryAsCurrent: item. item].!

hasExpired: key
    | item |
    item := self basicAt: key ifAbsent: [^false].
    ^self hasItemExpired: item.!

hasItemExpired: anItem
    ^(policy hasExpired: anItem) and: [(mainCache session isRegistered: (policy contentsOf: anItem)) not].!

includesKey: key
    "Return true if we include the object. Don't listen to any expiry policy"
    self basicAt: key ifAbsent: [^false].
    ^true.!

includesKey: key withClass: aClass
    "Return true if we include the object, and it matches our class. Don't listen to any expiry policy"
    | item value |
    item := self basicAt: key ifAbsent: [^false].
    value := policy contentsOf: item.
    ^value isKindOf: aClass.!

removeKey: key ifAbsent: aBlock
    ^items removeKey: key ifAbsent: aBlock.! !

!Cache methodsFor: 'accessing'!

cachePolicy: aCachePolicy
    policy := aCachePolicy.
    self initializeCache.!

mainCache
    ^mainCache!

mainCache: aCacheManager
    mainCache := aCacheManager!

numberOfElements
    ^items size.!

session
    ^mainCache session.! !

!Cache methodsFor: 'finalization'!

mournKeyOf: anEphemeron
    policy takeExpiryActionForKey: anEphemeron key withValue: anEphemeron value in: self.! !

!Cache methodsFor: 'initialize'!

initialize!
initializeCache
    items := policy newItemsIn: self.
    extraReferences := policy collectionForExtraReferences.!

release
    policy release: self.
    extraReferences := nil.! !

!Cache class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!Cache class methodsFor: 'instance creation'!

new
    ^super new initialize.!

newFor: aClass in: aCacheManager 
    | newCache descriptor |
    descriptor := aCacheManager session isNil ifFalse: [aCacheManager system descriptorFor: aClass].
    newCache := Cache new.
    newCache mainCache: aCacheManager.
    descriptor isNil 
    	ifTrue: [newCache cachePolicy: CachePolicy default]
    	ifFalse: [newCache cachePolicy: descriptor cachePolicy].
    ^newCache.! !

!FloatType methodsFor: 'converting'!

converterForStType: aClass
    ^self platform converterNamed: #numberToFloat.!

impliedSmalltalkType
    ^Float.! !

!FloatType methodsFor: 'initialize'!

initialize
    super initialize.
    typeString := 'float4'.! !

!FloatType class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPreparedStatement methodsFor: 'accessing'!

signature
    ^signature!

signature: aString
    signature := aString!

statement
    ^statement!

statement: aStatementHandle
    statement := aStatementHandle! !

!GlorpPreparedStatement methodsFor: 'initialize-release'!

initialize! !

!GlorpPreparedStatement methodsFor: 'As yet unclassified'!

glorpNoticeOfExpiryIn: aSession
    statement isNil ifFalse: [
    	| stmt |
    	stmt := statement.
    	statement := nil.
    	stmt dismiss].! !

!GlorpPreparedStatement class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPreparedStatement class methodsFor: 'instance creation'!

new
    "Answer a newly created and initialized instance."

    ^super new initialize! !

!FieldExpression methodsFor: 'accessing'!

base
    ^base.!

basicField
    ^field.!

canHaveBase
    "Return true if this type of expression can have a base expression on which other things can be built. Doesn't say whether we actually have a valid one or not."
    ^true.!

field
    ^base translateField: field! !

!FieldExpression methodsFor: 'navigating'!

ultimateBaseExpression
    ^base ultimateBaseExpression.! !

!FieldExpression methodsFor: 'preparing'!

asExpressionJoiningSource: source toTarget: target
    "Create a general expression which represents this relationship where the values of the targets (which are normally parameters) are supplied out of the context provided by 'target' and the source fields are referencing things out of the context of source. Produces something suitable for ANDing into an expression when doing a join
   Example: If we had CUSTOMER.ADDRESS_ID = ADDRESS.ID as a parameter, and we want to AND this into an expression [:customer | customer address street = 'Main'] then we have customer as a base, and we get 
    (customer.ADDRESS.STREET = 'Main') AND (customer.CUSTOMER.ADDRESS_ID = customer.ADDRESS.ID)
    The primary key expression for the relationship has been translated into field references into the customer and address tables in a particular context."
    | newTarget |
    newTarget := (target tables includes: field table) 
    	ifTrue: [target]
    	ifFalse: [base asExpressionJoiningSource: source toTarget: target].
    ^newTarget getField: field.!

tables
    ^base tables.!

tablesToPrint
    ^#().! !

!FieldExpression methodsFor: 'printing'!

printOnlySelfOn: aStream 
    base printsTable
    	ifTrue: [field printUnqualifiedSQLOn: aStream withParameters: #()]
    	ifFalse: [field printSQLOn: aStream withParameters: #()]!

printTreeOn: aStream 
    base printOn: aStream.
    aStream nextPut: $..
    base printsTable 
    	ifTrue: [field printUnqualifiedSQLOn: aStream withParameters: #()]
    	ifFalse: [field printSQLOn: aStream withParameters: #()]! !

!FieldExpression methodsFor: 'As yet unclassified'!

convertedDbValueOf: anObject
    "We don't do any conversion"
    ^anObject!

rebuildOn: aBaseExpression
    ^(base rebuildOn: aBaseExpression) getField: field.!

tableForANSIJoin
    ^self field table.! !

!FieldExpression methodsFor: 'printing SQL'!

printSQLOn: aStream withParameters: aDictionary
    self field printSQLOn: aStream withParameters:aDictionary.! !

!FieldExpression methodsFor: 'initializing'!

field: aField base: anObjectExpression
    field := aField.
    base := anObjectExpression.! !

!FieldExpression methodsFor: 'iterating'!

do: aBlock skipping: aSet
    "Iterate over the expression tree"

    (aSet includes: self) ifTrue: [^self].
    aSet add: self.
    base do: aBlock skipping: aSet.
    aBlock value: self.! !

!FieldExpression methodsFor: 'api'!

get: aSymbol withArguments: anArray
    | functionExpression |
    functionExpression := self getFunction: aSymbol withArguments: anArray.
    functionExpression isNil ifFalse: [^functionExpression].
    anArray isEmpty ifTrue: [self error: 'Field expressions do not have attributes'].
    ^RelationExpression named: aSymbol basedOn: self withArguments: anArray.! !

!FieldExpression class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!FieldExpression class methodsFor: 'instance creation'!

forField: aField basedOn: anObjectExpression
    ^self new field: aField base: anObjectExpression; yourself! !

!RelationshipMapping methodsFor: 'accessing'!

allTables
    mappingCriteria isNil ifTrue: [^#()].
    ^mappingCriteria allTables.!

mappedFields
    "Return a collection of fields that this mapping will write into any of the containing object's rows"

    ^self mappingCriteria allSourceFields.!

mappingCriteria
    "Private - Answer the value of the receiver's ''mappingCriteria'' instance variable."

    ^mappingCriteria!

mappingCriteria: anObject
    "Private - Set the value of the receiver's ''mappingCriteria'' instance variable to the argument, anObject."

    mappingCriteria := anObject!

referenceClass
    "Private - Answer the value of the receiver's ''referenceClass'' instance variable."

    ^referenceClass!

referenceClass: aClass
    "Private - Set the value of the receiver's ''referenceClass'' instance variable to the argument, anObject."

    aClass isBehavior ifFalse: [self error: 'reference class must be a class'].
    referenceClass := aClass!

referenceDescriptor
    ^self system descriptorFor: self referenceClass.!

shouldProxy
    ^shouldProxy.!

shouldProxy: aBoolean
    shouldProxy := aBoolean.! !

!RelationshipMapping methodsFor: 'testing'!

controlsTables
    "Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

    ^true!

isRelationship
    "True when the mapping associates different persistent classes."

    ^true!

isStoredInSameTable
    ^false! !

!RelationshipMapping methodsFor: 'initializing'!

initialize
    super initialize.
    shouldProxy := true.! !

!RelationshipMapping methodsFor: 'mapping'!

buildQuery
    self subclassResponsibility.!

extendedMappingCriteria
    ^mappingCriteria.!

isValidTarget: anObject
    ^anObject class == Proxy
    	ifTrue: [anObject isInstantiated]
    	ifFalse: ["anObject notNil" true].!

knit: ourObject to: anotherObject in: anObjectBuilder
    "Set up the relationship from our object to another one, indicated by our mapping"!

mapFromObject: anObject intoRowsIn: aRowMap 
    "Our target is a collection. The tricky bit is that if we're building rows into a RowMapForMementos, then the collection we contain isn't the one we want to use. We want the old version. Ask the row map to give it to us. If it's a normal row map, we'll just get the same thing back" 
    | target mementoizedTarget|
    readOnly ifTrue: [^self].
    target := self getValueFrom: anObject.
    target := self session realObjectFor: target ifNone: [^self].
    (self isValidTarget: target) ifTrue: [
    	mementoizedTarget := aRowMap collectionMementoFor: target.
    	self mapFromObject: anObject toTarget: mementoizedTarget puttingRowsIn: aRowMap].!

mapObject: anObject inElementBuilder: anElementBuilder
    | parameters |
    parameters := IdentityDictionary new.
    mappingCriteria
    	fieldsDo:
    		[:eachSource :eachTarget | parameters at: eachSource put: (anElementBuilder valueOfField: eachSource)].
    self
    	setValueIn: anObject
    	to:
    		(self shouldProxy
    			ifTrue:
    				[(self newProxy)
    					session: descriptor session;
    					parameters: parameters]
    			ifFalse:
    				[self query executeWithParameters: parameters in: descriptor session]).!

query
    query isNil ifTrue: [self buildQuery].
    ^query.! !

!RelationshipMapping methodsFor: 'preparing'!

joinExpressionFor: targetExpression
    "We're looking for the object represented by this mapping, and we know the object represented by its source. Use our mapping criteria to construct a join that traverses that instance of this relationship"

    | sourceExpression |
    sourceExpression := targetExpression base.
    ^self extendedMappingCriteria asExpressionJoiningSource: sourceExpression toTarget: targetExpression.!

multipleTableExpressionsFor: anExpression
    ^self referenceDescriptor multipleTableCriteria
    	collect: [:each | each asExpressionJoiningSource: anExpression toTarget: anExpression]! !

!RelationshipMapping methodsFor: 'api'!

referencedIndependentObjectsFrom: anObject
    ^self getValueFrom: anObject.! !

!RelationshipMapping methodsFor: 'processing'!

trace: aTracing context: anExpression
    "Currently we don't trace relationships across tables, so all we do here
is accumulate the list of embedded mappings"
    | newContext |
    (aTracing tracesThrough: self) ifFalse: [^self].
    newContext := anExpression get: attributeName.
    aTracing addExpression: newContext.
    self referenceDescriptor trace: aTracing context: newContext.! !

!RelationshipMapping methodsFor: 'proxies'!

newProxy
    | proxy |
    proxy := Proxy new.
    proxy query: (self query).
    ^proxy.! !

!RelationshipMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!OneToOneMapping methodsFor: 'mapping'!

buildQuery
    query := Query returningOneOf: referenceClass where: mappingCriteria.
    ^query.!

knit: ourObject to: anotherObject in: anObjectBuilder
    "Set up the relationship from our object to another one, indicated by our mapping"

    self setValueIn: ourObject to: anotherObject.!

mapFromObject: anObject toTarget: target puttingRowsIn: aRowMap 
    mappingCriteria 
    	mapFromSource: anObject
    	andTarget: target
    	intoRowsIn: aRowMap!

referencedIndependentObjectsFrom: anObject
    ^Array with: (self getValueFrom: anObject).! !

!OneToOneMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!EmbeddedValueOneToOneMapping methodsFor: 'preparing'!

joinExpressionFor: targetExpression
    "We're looking for the object represented by this mapping, and we know the object represented by its source. Use our mapping criteria to construct a join that traverses that instance of this relationship.
    Embedded values never induce a join."

    ^nil.! !

!EmbeddedValueOneToOneMapping methodsFor: 'transformations'!

defaultTransformationExpressionFor: aDescriptor 
    "If there's no transformation, get all the mapped fields from the other descriptor and construct a transformation of each onto itself. This lets us unify the fields in my row with the fields in its row"

    | fields transform |
    fields := IdentitySet new.
    aDescriptor mappings do: [:each | fields addAll: each mappedFields].
    transform := Join new.
    fields do: [:each | transform addSource: each target: each].
    ^transform!

hasTransformation
    ^false.!

transformationExpression
    ^self hasFieldTranslation
    	ifTrue: [fieldTranslation]
    	ifFalse: [self defaultTransformationExpressionFor: (self referenceDescriptor)].! !

!EmbeddedValueOneToOneMapping methodsFor: 'internal'!

fieldsForSelectStatement
    "Return a collection of fields that this mapping will read from a row"
    "Return nothing, because our sub-objects will take care of adding their own fields, translated correctly through us."
    ^#().!

mappedFields
    "Return a collection of fields that this mapping will write into any of the containing object's rows"

    fieldTranslation isNil ifFalse: [^fieldTranslation allSourceFields].
    ^self referenceDescriptor mappedFields.! !

!EmbeddedValueOneToOneMapping methodsFor: 'testing'!

controlsTables
    "Return true if this type of method 'owns' the tables it's associated with, and expression nodes using this mapping should alias those tables where necessary"

    ^false!

isStoredInSameTable
    ^true!

shouldProxy
    ^false.! !

!EmbeddedValueOneToOneMapping methodsFor: 'accessing'!

fieldTranslation
    ^fieldTranslation!

fieldTranslation: aPrimaryKeyExpression 
    fieldTranslation := aPrimaryKeyExpression!

hasFieldTranslation
    ^fieldTranslation notNil.! !

!EmbeddedValueOneToOneMapping methodsFor: 'mapping'!

mapFromObject: anObject toTarget: target puttingRowsIn: aRowMap 
    self transformationExpression 
    	mapFromSource: anObject
    	andTarget: target
    	intoRowsIn: aRowMap.

    (aRowMap rowsForKey: target) do: [:each | each shouldBeWritten: false]!

mapObject: anObject inElementBuilder: anElementBuilder
    | myTraceNode myBuilder |
    "If the object already has a value in my slot, then this it got a cache hit, the embedded value was carried along for the ride, and we don't need to assign anything"
    (self getValueFrom: anObject) isNil ifFalse: [^self].	"Otherwise, we need to look up the trace node that corresponds to this mapping, and get its instance"
    myTraceNode := anElementBuilder expression get: attributeName.
    myBuilder := anElementBuilder query elementBuilderFor: myTraceNode.
    self setValueIn: anObject to: myBuilder instance.!

translateFields: anOrderedCollection 
    fieldTranslation isNil ifTrue: [^anOrderedCollection].
    ^anOrderedCollection collect: [:each |
    	fieldTranslation sourceForTarget: each].! !

!EmbeddedValueOneToOneMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ToManyMapping methodsFor: 'mapping'!

add: anObject to: aCollection
    | newCollection |
    aCollection class == Array 
    	ifFalse: [^aCollection add: anObject].

    newCollection := aCollection, (Array with: anObject).
    self setValueIn: 3 to: newCollection.!

add: anObject to: aCollection in: ourObject
    "If this is an array we can't just add to it, we must concatenate and re-set the value"
    | newCollection |
    aCollection class == Array 
    	ifFalse: [^aCollection add: anObject].

    newCollection := aCollection, (Array with: anObject).
    self setValueIn: ourObject to: newCollection.!

knit: ourObject to: anotherObject in: anObjectBuilder
    "Set up the relationship from our object to another one, indicated by our mapping. If our instance ends up added to a collection, set the instance in the builder to be the collection so that it's the entire collection taht gets returned."
    | collection |
    collection := self getValueFrom: ourObject.
    (collection class == Proxy and: [collection isInstantiated not])
    	ifTrue:
    		[collection := self newCollection.
    		self setValueIn: ourObject to: collection.
    		self add: anotherObject to: collection in: ourObject.
    		^self].
    (collection includes: anotherObject)
    	ifFalse: [self add: anotherObject to: collection in: ourObject].!

newCollection
    ^self collectionType new.! !

!ToManyMapping methodsFor: 'api'!

collectionType
    collectionType isNil ifTrue: [collectionType := OrderedCollection].
    ^collectionType.!

collectionType: aClass
    collectionType := aClass.!

orderBy
    ^orderBy.!

orderBy: aBlockOrSelector
    orderBy isNil ifTrue: [orderBy := OrderedCollection new].
    orderBy add: aBlockOrSelector.!

referencedIndependentObjectsFrom: anObject
    | collection |
    collection := super referencedIndependentObjectsFrom: anObject.
    collection == nil ifTrue: [^#()].
    ^Array with: collection.!

shouldWriteTheOrderField
    ^shouldWriteTheOrderField!

shouldWriteTheOrderField: aBoolean
    shouldWriteTheOrderField := aBoolean.!

writeTheOrderField
    shouldWriteTheOrderField := true.! !

!ToManyMapping methodsFor: 'private/expressions'!

orderField
    ^(orderBy first asGlorpExpressionOn: (BaseExpression new descriptor: self descriptor)) field.! !

!ToManyMapping methodsFor: 'initialize/release'!

initialize
    super initialize.
    shouldWriteTheOrderField := false.! !

!ToManyMapping methodsFor: 'testing'!

isToManyRelationship
    ^true.! !

!OneToManyMapping methodsFor: 'mapping'!

buildQuery
    query := Query returningManyOf: referenceClass where: mappingCriteria.
    orderBy isNil ifFalse: [orderBy do: [:each | query orderBy: each]].
    query collectionType: self collectionType.
    ^query.!

mapFromObject: anObject toTarget: aCollection puttingRowsIn: aRowMap 
    | index |
    aCollection isNil ifTrue: [^self].
    index := 1.
    aCollection do: [:each | 
    	(self isValidTarget: each) ifTrue: [
    		mappingCriteria 
    			mapFromSource: anObject
    			andTarget: each
    			intoRowsIn: aRowMap.
    	shouldWriteTheOrderField ifTrue: [
    			FieldUnifier 
    				unifyFields: (Array with: (ConstantExpression new value: index) with: self orderField)
    				correspondingTo: (Array with: each with: each)
    				in: aRowMap].
    		index := index + 1]].! !

!OneToManyMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!ManyToManyMapping methodsFor: 'mapping'!

buildQuery
    |  criteria |
    criteria := mappingCriteria asGeneralGlorpExpression.
    query := Query returningManyOf: referenceClass
    	where: criteria.
    query joins add: (self expressionFromLinkToReferenceTableWithBase: query baseExpression).
    orderBy isNil ifFalse: [orderBy do: [:each | query orderBy: each]].
    query collectionType: self collectionType.
    ^query.!

extendedMappingCriteria
    "In order to do a many-to-many read we need more information than just the write, we need to know 
    the relationship to the other table. Construct that based on the table information"

    | generalMappingCriteria base |
    generalMappingCriteria := mappingCriteria asGeneralGlorpExpression.
    base := generalMappingCriteria ultimateBaseExpression.
    ^generalMappingCriteria AND: 
    	(self expressionFromLinkToReferenceTableWithBase: base) .!

mapFromObject: anObject toTarget: aCollection puttingRowsIn: aRowMap
    | reverseMappingCriteria index |
    reverseMappingCriteria := self
    	primaryKeyExpressionFromLinkToReferenceTable.	"This is interesting. We could test if we're writing the ordering into a field, and if we are assume this is sequenceable and iterate differently. But it actually seems easier to just use do: and maintain a separate index"
    index := 1.
    aCollection
    	do:
    		[:each | 
    		(self isValidTarget: each)
    			ifTrue:
    				[| rowMapKey |
    				rowMapKey := self rowMapKeyForSource: anObject target: each.
    				mappingCriteria
    					mapFromSource: anObject
    					andTarget: rowMapKey
    					intoRowsIn: aRowMap.
    				reverseMappingCriteria
    					mapFromSource: rowMapKey
    					andTarget: each
    					intoRowsIn: aRowMap.
    				shouldWriteTheOrderField
    					ifTrue:
    						[| keyForOrdering |
    						keyForOrdering := self orderField table == self linkTable
    							ifTrue: [rowMapKey]
    							ifFalse: [each].
    						FieldUnifier
    							unifyFields:
    								(Array with: (ConstantExpression new value: index) with: self orderField)
    							correspondingTo: (Array with: keyForOrdering with: keyForOrdering)
    							in: aRowMap].
    				index := index + 1]].!

rowMapKeyForSource: each target: anObject
    ^rowMapKeyConstructorBlock isNil
    	ifTrue:
    		[(RowMapKey new)
    			key1: anObject;
    			key2: each]
    	ifFalse: [rowMapKeyConstructorBlock value: each value: anObject].! !

!ManyToManyMapping methodsFor: 'private/expressions'!

constraints
    | referenceKeys linkTable referenceTables allConstraints relevantConstraints |
    referenceKeys := mappingCriteria targetKeys asOrderedCollection.
    linkTable := referenceKeys first table.
    "If we haven't been told the relevant link table fields, assume we can find them by looking at all the ones that aren't the ones from our source to the link, and all the rest will be from the link to the target"
    allConstraints := linkTable foreignKeyConstraints.
    relevantConstraints := relevantLinkTableFields isNil 
    	ifTrue: [allConstraints reject: [:each |  (referenceKeys includes: each sourceField)]]
    	ifFalse: [allConstraints select: [:each | relevantLinkTableFields includes: each sourceField]].

    "Validate that we can handle this case"
    referenceTables := (relevantConstraints collect: [:each | each targetField table]) asSet.
    referenceTables size > 1 ifTrue: [self error: 'Cannot handle this general a case'].
    referenceTables size = 0 ifTrue: [self error: 'No tables found. Did you set up foreign key references in the table definitions?'].

    ^relevantConstraints.!

expressionFromLinkToReferenceTableWithBase: base
    "Unfortunately we can't just convert the primary key expression into our expression, because that would generate targets as parameters, and we want both to be fields"
    | expression |
    expression := nil.
    self constraints do: [:each | |src target |
    	src := (base getTable: each sourceField table) getField: each sourceField.
    	target := (base getTable: each targetField table) getField: each targetField.
    	expression := expression isNil 
    		ifTrue: [src equals: target]
    		ifFalse: [expression AND: (src equals: target)]].
    ^expression.!

linkTable
    | referenceKeys |
    referenceKeys := mappingCriteria targetKeys asOrderedCollection.
    ^referenceKeys first table.!

primaryKeyExpressionFromLinkToReferenceTable
    "Generate the inverse mapping expression, i.e. the one connecting the link table to the reference table, using the foreign key constraints."

    | expression |
    expression := Join new.
    self constraints do: [:each | 
    	expression addSource: each sourceField target: each targetField].
    ^expression.! !

!ManyToManyMapping methodsFor: 'api'!

constructRowMapKeyAs: aBlock
    "Give us the opportunity to construct a custom row map key. This is useful if you need to force two relationships to share a link table entry"
    rowMapKeyConstructorBlock := aBlock.!

relevantLinkTableFields: aCollection
    relevantLinkTableFields := aCollection.! !

!ManyToManyMapping class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!AddingWriteStream class methodsFor: 'instance creation'!

on: aCollection
    ^self new target: aCollection.! !

!Smalltalk.SequenceableCollection methodsFor: 'accessing'!

atIndex: anInteger
    "For compatibility with Dolphin and VA data base rows."
    ^self at: anInteger.! !

!Smalltalk.Time methodsFor: 'printing'!

glorpPadToTwoDigits: anInteger
    | string |
    string := anInteger printString.
    ^string size = 1 ifTrue: ['0', string] ifFalse: [string].!

glorpPrintSQLOn: aStream
    "Print as 24 hour time"

    aStream 
    	nextPut: $';
    	nextPutAll: 	(self glorpPadToTwoDigits: self hours);
    	nextPut: $:;
    	nextPutAll: (self glorpPadToTwoDigits: self minutes);
    	nextPut: $:;
    	nextPutAll: (self glorpPadToTwoDigits: self seconds);
    	nextPut: $'.! !

!Smalltalk.UndefinedObject methodsFor: 'printing'!

glorpPrintSQLOn: aStream
    aStream nextPutAll: 'NULL'.! !

!Smalltalk.Date methodsFor: 'printing'!

glorpPrintSQLOn: aStream
    "Print the date in ISO format. 'yyyy-mm-dd'  Don't rely on any dialect-specific formatting or padding mechanisms"
    | monthString dayString |
    aStream 
    	nextPut: $';
    	print: self year;
    	nextPut: $-.
    monthString := self monthIndex printString.
    monthString size = 1 ifTrue: [aStream nextPut: $0 ].
    aStream nextPutAll: monthString.
    aStream nextPut: $-.
    dayString := self dayOfMonth printString.
    dayString size = 1 ifTrue: [aStream nextPut: $0 ].
    aStream nextPutAll: dayString.
    aStream nextPut: $'.! !

!Smalltalk.Object methodsFor: 'glorp'!

asGlorpExpression
    ^Glorp.ConstantExpression for: self.!

asGlorpExpressionOn: anExpression
    ^self asGlorpExpression.!

glorpIsCollection
    ^false.!

glorpPostFetch: aSession!
glorpPostWrite: aSession!
glorpPreWrite: aSession!
glorpPrintSQLOn: aStream
    self printOn: aStream.!

isGlorpExpression
    ^false.!

needsWork: aString
    ^self.!

todo
    "marker"! !

!GlorpHelper class methodsFor: 'glorp'!

glorpBaseExpressionClass
    "This is to work around Dolphin's obnoxious insistence on absolute prerequisite enforcement. We have to define extension methods on blocks for asGlorpExpression. These need to create a messageArchiver. Those have to be in the dialect-specific prereq, but since that gets loaded before anything else it can't reference Glorp classes. So have it send a message instead"
    ^BaseExpression!

glorpMessageArchiverClass
    "This is to work around Dolphin's obnoxious insistence on absolute prerequisite enforcement. We have to define extension methods on blocks for asGlorpExpression. These need to create a messageArchiver. Those have to be in the dialect-specific prereq, but since that gets loaded before anything else it can't reference Glorp classes. So have it send a message instead"
    ^MessageArchiver!

!Smalltalk.ByteArray methodsFor: 'testing'!

glorpIsCollection
    "For our purposes, these aren't collections, but rather a simple database type"
    ^false.! !

!Smalltalk.ReadStream methodsFor: 'Not categorized'!

collect: aBlock 
    | newStream |
    newStream := WriteStream on: collection species new.
    [self atEnd] whileFalse: [newStream nextPut: (aBlock value: self next)].
    ^newStream contents! !

!Smalltalk.String methodsFor: 'glorp'!

glorpIsCollection
    "For our purposes, these aren't collections, but rather a simple database type"
    ^false.!

glorpPrintSQLOn: aStream 
    | requireEscape |
    requireEscape := #($' $" $\).
    aStream nextPut: $'.
    1 to: self size
    	do: 
    		[:i | 
    		(requireEscape includes: (self at: i)) ifTrue: [aStream nextPut: $\].
    		aStream nextPut: (self at: i)].
    aStream nextPut: $'! !

!Smalltalk.Collection methodsFor: 'testing'!

glorpIsCollection
    ^true.! !

!Smalltalk.Collection methodsFor: 'glorp'!

glorpPrintSQLOn: aStream 
    aStream nextPut: $(.
    Glorp.GlorpHelper  do: [:each | each glorpPrintSQLOn: aStream]
    	for: self
    	separatedBy: [aStream nextPutAll: ', '].
    aStream nextPut: $)!

glorpPrintSQLOn: aStream for: aType
    aStream nextPut: $(.
    Glorp.GlorpHelper 
    	do: [:each | aType print: each on: aStream]
    	for: self
    	separatedBy: [aStream nextPutAll: ', '].
    aStream nextPut: $)!

glorpRegisterCollectionInternalsIn: anObjectTransaction 
    "Explicitly register any internal structures (e.g. a VW identity dictionary's valueArray) with the transaction. Assume we can safely register everything inside the collection reflectively. The obvious exceptions would be dependents and sortblocks. This is a cheat, and for peculiar cases you'll need to override this in the subclass"

    | names |
    names := self class allInstVarNames.
    (1 to: names size) do: 
    		[:index | 
    		(#('dependents' 'sortBlock') includes: (names at: index)) 
    			ifFalse: [anObjectTransaction register: (self instVarAt: index)]]! !

Glorp.FunctionExpression initialize!
