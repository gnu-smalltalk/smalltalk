Smalltalk addSubspace: #GlorpTestNamespace!

TestCase subclass: #GlorpTestCase
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpTestCase subclass: #GlorpDatabaseTypeDBTests
    instanceVariableNames: 'type stType connection session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpTestCase subclass: #GlorpDeleteTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpSimpleQueryTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpMappingDBTest
    instanceVariableNames: 'system session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpMappingDBTest subclass: #GlorpDirectMappingDBTest
    instanceVariableNames: 'person personId '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpMappingDBTest subclass: #GlorpOneToManyDBTest
    instanceVariableNames: 'person personId emailId1 emailId2 emailId3 '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpMappingDBTest subclass: #GlorpDatabaseTableTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpDatabaseTypeTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpWorker
    instanceVariableNames: 'id name pendingJobs finishedJobs priorityJobs '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpBasicMappingTest
    instanceVariableNames: 'mapping person '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpOffice
    instanceVariableNames: 'id employees street employeeOfMonth '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpConstantMappingTest
    instanceVariableNames: 'mappingToClass mappingToRow mappingToSession slot '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpCompressedMoney
    instanceVariableNames: 'id array '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

Smalltalk.Object subclass: #GlorpThingOne
    instanceVariableNames: 'id name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpCollectionTypeModels'!

GlorpThingOne comment: '
This just exists to be put in collections.

Instance Variables:
    id	<SmallInteger>	description of id
    name	<String>	description of name

'!


Smalltalk.Object subclass: #GlorpMoney
    instanceVariableNames: 'currency amount '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpDatabaseLoginTest
    instanceVariableNames: 'login accessor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpDatabaseSessionTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

AbstractReadQuery subclass: #GlorpQueryStub
    instanceVariableNames: 'result '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpCoreExtensionstest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpBankAccount
    instanceVariableNames: 'id accountNumber accountHolders eventsReceived '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

Smalltalk.Object subclass: #GlorpBankTransaction
    instanceVariableNames: 'id owner amount serviceCharge '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpReadingDifferentCollectionsTest
    instanceVariableNames: 'system session singleQuery allQuery singleResult allResult '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpObjectWithNoAccessors
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpExpressionIterationTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

TestResource subclass: #GlorpDatabaseLoginResource
    instanceVariableNames: 'accessor login '
    classVariableNames: 'DefaultLogin'
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpDatabaseBasedTest
    instanceVariableNames: 'system '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpPrimaryKeyExpressionWithConstantTest
    instanceVariableNames: 'expression compoundExpression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpPrimaryKeyExpressionTest
    instanceVariableNames: 'expression compoundExpression '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpSessionTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpExpressionJoiningTest
    instanceVariableNames: 'source target base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpDirectMappingTest
    instanceVariableNames: 'mapping '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpRowDifferencingTest
    instanceVariableNames: 'session currentObject currentObjectRowMap correspondenceMap differenceMap mementoObject mementoObjectRowMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpPartialWritesTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpThingWithLotsOfDifferentCollections
    instanceVariableNames: 'id array orderedCollection set bag sortedCollection name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpCollectionTypeModels'!

GlorpTestCase subclass: #GlorpTracingTest
    instanceVariableNames: 'tracing '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpEncyclopedia
    instanceVariableNames: 'id entries '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpExpressionBasicPropertiesTest
    instanceVariableNames: 'base '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpCustomer
    instanceVariableNames: 'id name transactions accounts accountsSortedById accountsSortedByIdDescending eventsReceived seenPostFetch seenPreWrite seenPostWrite seenExpiry '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpDatabaseBasedTest subclass: #GlorpCommitOrderTest
    instanceVariableNames: 't1 t2 t3 t1id t2id t3id platform '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpMappingDBTest subclass: #GlorpOneToOneDBTest
    instanceVariableNames: 'person personId '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpReadingPersonWithEmailAddressesTest
    instanceVariableNames: 'session personRow addressRow emailAddress1Row emailAddress2Row id1 id2 '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpReadQueryTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

DescriptorSystem subclass: #GlorpTestDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp'!

GlorpTestDescriptorSystem comment: '
This is an abstract superclass for all descriptor systems whose tables should be set up as part of the standard GLORP testing process. See GlorpDemoTablePopulatorResource.'!


GlorpTestDescriptorSystem subclass: #GlorpDemoDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: 'Default'
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestDescriptorSystem subclass: #GlorpWorkerDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestDescriptorSystem subclass: #GlorpCollectionTypesDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpCollectionTypeModels'!

Smalltalk.Object subclass: #GlorpJob
    instanceVariableNames: 'id description '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpDatabaseBasedTest subclass: #GlorpExpressionTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpFakeElementBuilder
    instanceVariableNames: 'value '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpPerson
    instanceVariableNames: 'id name address emailAddresses '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpDatabaseBasedTest subclass: #GlorpTableTest
    instanceVariableNames: 'descriptors dbPlatform '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpEncyclopediaEntry
    instanceVariableNames: 'id name text '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

Smalltalk.Object subclass: #GlorpAirline
    instanceVariableNames: 'id name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpWritingTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpTestDescriptorSystem subclass: #GlorpEncyclopediaDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

DatabaseCommand subclass: #GlorpNullCommand
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpCore'!

GlorpNullCommand comment: '
This represents a command with no additional syntax, basically just a stream. Useful for testing the generation of chunks of SQL.'!


GlorpTestCase subclass: #GlorpConstantValueInRelationshipTest
    instanceVariableNames: 'session system '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpUnitOfWorkTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

DatabaseAccessor subclass: #GlorpMockAccessor
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpDatabase'!

Smalltalk.Object subclass: #GlorpTypeTestsModelClass
    instanceVariableNames: 'id test '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

Smalltalk.Object subclass: #GlorpItinerary
    instanceVariableNames: 'id reservation '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpItinerary comment: '
An itinerary holds onto a single reservation. It may not make much sense, but we need to test another layer of indirection.
'!


Smalltalk.Object subclass: #GlorpPassenger
    instanceVariableNames: 'id name frequentFlyerMiles airline '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpDictionaryMappingTest
    instanceVariableNames: 'system '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpReadingTest
    instanceVariableNames: 'system session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpReadingTest comment: '
This tests the full reading mechanism, writing out some rows manually and then doing various read operations.

Instance Variables:
    session	<Session>	
    system	<GlorpDemoDescriptorSystem>	

'!


GlorpTestCase subclass: #GlorpDatabasePlatformTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpReservation
    instanceVariableNames: 'id passenger passengers '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpDialectTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDialectTest comment: '
Tests the portability methods in the Dialect class.'!


GlorpTestCase subclass: #GlorpDatabaseTypeIndividualDBTests
    instanceVariableNames: 'type stType connection session table '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpVarchar10Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

Smalltalk.Object subclass: #GlorpBankAccountNumber
    instanceVariableNames: 'bankCode branchNumber accountNumber '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpVarchar2Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpBooleanTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpInt4Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpNumericTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpTimeTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpVarchar1Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpVarchar4Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpTextTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpTimestampTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpNumeric52Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpChar2Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpFloat4Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpInt8Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpChar4Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseBasedTest subclass: #GlorpMappingTest
    instanceVariableNames: 'rowMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpDescriptorTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpHorizontalInheritanceTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpTestCase subclass: #GlorpProxyTest
    instanceVariableNames: 'session proxy '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpDatabaseBasicTest
    instanceVariableNames: 'system '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpInsertUpdateTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpAirlineMeal
    instanceVariableNames: 'id description ingredients '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

Smalltalk.Object subclass: #GlorpExampleSystem
    instanceVariableNames: 'objects '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpExampleSystem subclass: #GlorpBankExampleSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpWorkingStiff
    instanceVariableNames: 'id name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpWorkingStiff subclass: #GlorpEmployee
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpEmployee subclass: #GlorpLineWorker
    instanceVariableNames: 'productionLine '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpEmployee subclass: #GlorpManager
    instanceVariableNames: 'branch '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpManager subclass: #GlorpRegionalManager
    instanceVariableNames: 'region '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpDatabaseBasedTest subclass: #GlorpCacheTest
    instanceVariableNames: 'cache session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpCacheTest subclass: #GlorpTimedExpiryCacheTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpFilteredInheritanceTest
    instanceVariableNames: 'session allEmployees '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpTestCase subclass: #GlorpSQLPrintingTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpTests'!

GlorpTestDescriptorSystem subclass: #GlorpDescriptorSystemWithNamespaces
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: 'GlorpTestNamespace'
    category: 'Glorp-Tests'!

TestResource subclass: #GlorpSessionResource
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpMessageCollectorTest
    instanceVariableNames: 'collector '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpServiceCharge
    instanceVariableNames: 'description amount '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpDatabaseBasedTest subclass: #GlorpSessionBasedTest
    instanceVariableNames: 'session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpSessionBasedTest subclass: #GlorpVirtualCollectionBasicTest
    instanceVariableNames: 'vc '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpTests'!

GlorpCacheTest subclass: #GlorpWeakCacheTest
    instanceVariableNames: 'mourned '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpFloat8Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpNumeric5Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpDatabaseBasedTest subclass: #GlorpQueryTableAliasingTest
    instanceVariableNames: 'query expression elementBuilder session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestDescriptorSystem subclass: #GlorpInheritanceDescriptorSystem
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'GlorpMappings'!

GlorpDatabaseBasedTest subclass: #GlorpAdHocMappingTest
    instanceVariableNames: 'mapping person descriptor table money rowMap '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpInventoryItem
    instanceVariableNames: 'id name '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpInventoryItem subclass: #GlorpPerishableItem
    instanceVariableNames: 'age '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpPerishableItem subclass: #GlorpPoultry
    instanceVariableNames: 'featherColor '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpInventoryItem subclass: #GlorpNonperishableItem
    instanceVariableNames: 'serialNumber '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpNonperishableItem subclass: #GlorpUnassembledItem
    instanceVariableNames: 'assemblyCost '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpDatabaseAccessorTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpIntegerTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

Smalltalk.Object subclass: #GlorpTransformedTime
    instanceVariableNames: 'id time '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTransformedTime comment: '
This class just holds a time, but that time is transformed into a representation in seconds in the database.

Instance Variables:
    id	<Integer>	The primary key
    time	<Time>	The time

'!


GlorpDatabaseBasedTest subclass: #GlorpExpressionTableAliasingTest
    instanceVariableNames: 'exp '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseBasedTest subclass: #GlorpQueryCopyingTest
    instanceVariableNames: 'query expression elementBuilder session newQuery '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpAddress
    instanceVariableNames: 'id street number '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpAttributeAccessorTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpDeleteInUnitOfWorkTest
    instanceVariableNames: 'unitOfWork '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpSession subclass: #GlorpMockSession
    instanceVariableNames: 'rows '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpTestCase subclass: #GlorpReadingDifferentCollectionsThroughMappingsTest
    instanceVariableNames: 'system session '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpMappingDBTest subclass: #GlorpManyToManyDBTest
    instanceVariableNames: 'customer customerId accountId1 accountId2 accountId3 '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Namespace current: GlorpTestNamespace!

Smalltalk.Object subclass: #GlorpTestClassInNamespace
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

Namespace current: Glorp!

TestResource subclass: #GlorpDemoTablePopulatorResource
    instanceVariableNames: 'login '
    classVariableNames: 'NeedsSetup'
    poolDictionaries: ''
    category: 'Glorp-Tests'!

Smalltalk.Object subclass: #GlorpEmailAddress
    instanceVariableNames: 'id user host '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-TestModels'!

GlorpTestCase subclass: #GlorpRowMapUnificationTest
    instanceVariableNames: 't1 t2 t3 f1 f2 f3 o1 o2 o3 rowMap platform '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpInt2Test
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!

GlorpTestCase subclass: #GlorpObjectTransactionTest
    instanceVariableNames: 'transaction objects '
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-Tests'!

GlorpDatabaseTypeIndividualDBTests subclass: #GlorpDateTest
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Glorp-DBTests'!



!GlorpTestCase methodsFor: 'tests'!

defaultLogPolicyClass
    ^TestVerboseLog! !

!GlorpDatabaseTypeDBTests methodsFor: 'tests'!

testSerial
    "type := PGSerialType instance.
    self assert: false.

    self assert: (type typeString = 'SERIAL')"!

testTimeWithTimeZone
    | time |
    "
    type := PGTimeWithTimeZoneType instance.
    time := Dialect timestampNow.

    self assert: false. This needs some thought.
    self assert: (self helpTestType: type withValue: time).	
    self assert: (type typeString = 'TIME WITH TIME ZONE')"!

testTypeParametersNotAliased
    | type2 type3 |
    type := (self platform) varchar.
    self assert: type width isNil.
    self assert: (type2 := self platform varChar: 5) width = 5.
    self assert: type width isNil.
    type3 := self platform varChar: 10.
    self assert: type3 width = 10.
    self assert: type2 width = 5.
    self assert: type width isNil.!

testVarBinary
    "Needs doing"
    self needsWork: 'write the test'.! !

!GlorpDatabaseTypeDBTests methodsFor: 'infrastructure tests'!

testReadTime
    self platform readTime: '18:06:22.12' for: self platform time.! !

!GlorpDatabaseTypeDBTests methodsFor: 'setup'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    connection := session accessor.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpDatabaseTypeDBTests methodsFor: 'accessing'!

platform
    ^connection platform! !

!GlorpDatabaseTypeDBTests class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDeleteTest methodsFor: 'tests'!

checkCustomerDeletedInDatabase
    | result |
    result := session accessor 
    			executeSQLString: 'SELECT * FROM GR_CUSTOMER WHERE ID=1'.
    self assert: result isEmpty!

checkCustomerNotInCache
    self assert: (session cacheLookupForClass: GlorpCustomer key: 1) isNil!

checkCustomerStillInCache
    self assert: (session cacheLookupForClass: GlorpCustomer key: 1) notNil!

checkPersonDeletedInDatabase
    | result |
    result := session accessor 
    			executeSQLString: 'SELECT * FROM PERSON WHERE ID=1'.
    self assert: result isEmpty!

setUpCustomer
    session beginTransaction.
    session accessor 
    	executeSQLString: 'INSERT INTO GR_CUSTOMER VALUES (1,''Fred Flintstone'')'.
    ^session readOneOf: GlorpCustomer where: [:each | each id = 1].!

setUpPersonWithAddress
    session beginTransaction.
    session accessor 
    	executeSQLString: 'INSERT INTO GR_ADDRESS VALUES (2,''Paseo Montril'', 999)'.
    session accessor 
    	executeSQLString: 'INSERT INTO PERSON VALUES (1,''Fred Flintstone'', 2)'.
    ^session readOneOf: GlorpPerson where: [:each | each id = 1].!

testExecute
    | customer query |
    self needsWork: ''.
"	[customer := self setUpCustomer.
    self assert: (session cacheLookupForClass: Customer key: 1) == customer.
    query := DeleteQuery for: customer.
    session execute: query.
    self checkCustomerDeletedInDatabase.
    self checkCustomerNotInCache] 
    		ensure: [session rollbackTransaction]"!

testUnitOfWorkDelete
    | customer result |
    
    [customer := self setUpCustomer.
    session beginUnitOfWork.
    session delete: customer.
    result := session accessor 
    			executeSQLString: 'SELECT * FROM GR_CUSTOMER WHERE ID=1'.
    self assert: result size = 1.
    self 
    	assert: (session readOneOf: GlorpCustomer where: [:each | each id = 1]) isNil.
    self checkCustomerStillInCache.
    session commitUnitOfWork.
    self checkCustomerNotInCache.
    self checkCustomerDeletedInDatabase] 
    		ensure: [session rollbackTransaction]!

testUnitOfWorkDeleteOrder
    | person |
    
    [person := self setUpPersonWithAddress.
    session beginUnitOfWork.
    session delete: person.
    session delete: person address.
    session commitUnitOfWork.
    self checkPersonDeletedInDatabase.] 
    		ensure: [session rollbackTransaction]! !

!GlorpDeleteTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpDeleteTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpSimpleQueryTest methodsFor: 'tests'!

setUpQueryBasic: query 
    | |
    query session: session.
    query setUpCriteria.
    query setupTracing.!

setUpQueryFields: query 
    self setUpQueryBasic: query.
"	query setupTracing."
    query computeFields.!

setUpQueryFully: query 
    self setUpQueryBasic: query.
    query prepare!

skipToString
    ^session platform supportsANSIJoins ifTrue: ['join '] ifFalse: ['where '].!

testCaseInsensitiveQuery
    | result |
    session platform supportsCaseInsensitiveLike ifFalse: [^self].
    [session beginUnitOfWork.
    session beginTransaction.
    session register: GlorpAddress example1.
    session commitUnitOfWork.
    result := session
    			readOneOf: GlorpAddress
    			where: [:address | address street ilike: 'WeSt%'].
    self assert: result street = 'West 47th Ave'] 
    		ensure: [session rollbackTransaction]!

testComputingFieldsForDirectMappings
    | query table |
    query := SimpleQuery returningOneOf: GlorpAddress where: [:each | each id = 1].
    self setUpQueryFields: query.
    
    table := session system tableNamed: 'GR_ADDRESS'.
    self assert: (query fields = table fields).!

testComputingFieldsForReferenceMappings
    | query table |
    query := SimpleQuery returningOneOf: GlorpPerson where: [:each | each id = 1].
    self setUpQueryFields: query.
    
    table := session system tableNamed: 'PERSON'.
    self assert: (query fields = table fields).!

testDescriptorAssignmentToCriteria
    | query |
    query := SimpleQuery returningOneOf: GlorpAddress where: [:each | each id = 1].
    query session: session.
    query setUpCriteria.
    self assert: query criteria ultimateBaseExpression descriptor == (session descriptorFor: GlorpAddress).!

testFieldAliasingForEmbeddedMappings
    | query table |
    query := SimpleQuery returningOneOf: GlorpBankTransaction where: [:each | each id = 1].
    self setUpQueryFields: query.
    table := session system tableNamed: 'BANK_TRANS'.
    self assert: (query fields = table fields).
    self assert: (query builders first translateFieldPosition: (table fieldNamed: 'ID')) = 1.
    self assert: (query builders first translateFieldPosition: (table fieldNamed: 'OWNER_ID')) = 2.!

testPrimaryKeyExpressionWithMultipleTables
    | query sql sqlStream result command |
    query := SimpleQuery returningOneOf: GlorpPassenger where: [:each | each id = 1].
    query session: session.
    query prepare.
    command := query sqlWith: Dictionary new.
    command useBinding: false.
    sql := command sqlString.
    sqlStream := ReadStream on: sql asLowercase.
    sqlStream skipToAll: self skipToString.
    Dialect isVisualWorks ifTrue: [sqlStream skip: self skipToString size].	"<Grumble grumble> stupid incompatibilities"
    result := sqlStream upToEnd.
    session platform supportsANSIJoins ifTrue: [
    	self assert: result = 'frequent_flyer t2 on (t1.id = t2.id))
 where (t1.id = 1)']
    	ifFalse: [self assert: result = '(t1.id = 1) and ((t1.id = t2.id))'].! !

!GlorpSimpleQueryTest methodsFor: 'tests-ordering'!

testDoubleOrderSQL
    | query sql |
    query := SimpleQuery returningManyOf: GlorpAddress.
    query orderBy: [:each | each id].
    query orderBy: [:each | each number].
    self setUpQueryFully: query.
    sql := (query sqlWith: Dictionary new) sqlString.
    self assert: ('* from gr_address t1 order by t1.id, t1.house_num' match: sql asLowercase).!

testOrderSQL
    | query sql |
    query := SimpleQuery returningManyOf: GlorpAddress.
    query orderBy: [:each | each id].
    self setUpQueryFully: query.
    sql := (query sqlWith: Dictionary new) sqlString.
    self assert: ('* from gr_address t1 order by t1.id' match: sql asLowercase).! !

!GlorpSimpleQueryTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpSimpleQueryTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpSimpleQueryTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpMappingDBTest methodsFor: 'support'!

inTransactionDo: aBlock
    [session beginTransaction.
    aBlock value] ensure: [session rollbackTransaction].!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    system := session system.!

tearDown
    super tearDown.
    session reset.
    session := nil.
    system := nil.! !

!GlorpMappingDBTest class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDirectMappingDBTest methodsFor: 'tests'!

readPerson
    | results query |
    query := Query
    	returningManyOf: GlorpPerson
    	where: [:pers | pers id = personId].
    results := query executeIn: session.
    self assert: results size = 1.
    person := results first.!

testModify
    |newPerson |
    self inTransactionDo: [
    	session beginUnitOfWork.
    	newPerson := GlorpPerson example1.
    	personId := newPerson id.
    	session register: newPerson.
    	session commitUnitOfWork.
    	session reset.
    	self readPerson.
    	session inUnitOfWorkDo: [
    		session register: person.
    		person name: 'something else'].
    	session reset.
    	self readPerson.
    	self assert: person id = newPerson id.
    	self assert: person name = 'something else'].! !

!GlorpDirectMappingDBTest class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpOneToManyDBTest methodsFor: 'support'!

checkEmailAddresses: emailAddresses
    | sorted numberOfAddresses |
    numberOfAddresses := (emailId1 isNil ifTrue: [0] ifFalse: [1]) + (emailId2 isNil ifTrue: [0] ifFalse: [1]) + (emailId3 isNil ifTrue: [0] ifFalse: [1]).
    self assert: emailAddresses size = numberOfAddresses.
    sorted := emailAddresses asSortedCollection: [:a :b | a id <= b id].
    emailId1 isNil ifFalse: [self assert: sorted first id = emailId1].
    emailId2 isNil ifFalse: [self assert: (sorted at: 2) id = emailId2].
    emailId3 isNil ifFalse: [self assert: sorted last id = emailId3].
    self assert: (emailAddresses collect: [:each | each id]) asSet size = emailAddresses size.!

checkNumberOfEmailAddressesInDB: numberOfAddresses
    | databaseAddresses |
    databaseAddresses := session accessor executeSQLString: 'SELECT * FROM EMAIL_ADDRESS'.
    self assert: databaseAddresses size = numberOfAddresses.!

inUnitOfWorkDo: aBlock initializeWith: initBlock
    "Set up a bunch of the normal data, read the objects, then run the block in a unit of work"
    initBlock value.
    session beginUnitOfWork.
    self readPerson.
    aBlock value.
    session commitUnitOfWork.
    session reset.!

readPerson
    | results query |
    query := Query
    	returningManyOf: GlorpPerson
    	where: [:pers | pers id = personId].
    results := query executeIn: session.
    self assert: results size = 1.
    person := results first.!

writePersonWithEmailAddresses
    | addressRow personRow emailAddress1Row emailAddress2Row |
    addressRow := session system exampleAddressRow.
    session writeRow: addressRow.
    personRow := session system examplePersonRow1.
    personId := personRow atFieldNamed: 'ID'.
    session writeRow: personRow.
    emailAddress1Row := session system exampleEmailAddressRow1.
    emailAddress2Row := session system exampleEmailAddressRow2.
    emailId1 := emailAddress1Row at: (emailAddress1Row table fieldNamed: 'ID').
    emailId2 := emailAddress2Row at: (emailAddress2Row table fieldNamed: 'ID').
    session writeRow: emailAddress1Row.
    session writeRow: emailAddress2Row.! !

!GlorpOneToManyDBTest methodsFor: 'tests-read'!

testReadJustTheEmailAddressNotThePersonAndWriteBackWithChanges
    | addresses addressRows |
    "We won't have the person object to set a value for the PERSON_ID field. Ensure that we don't write a null for that field, or otherwise modify things."
    self inTransactionDo: [	
    	self writePersonWithEmailAddresses.
    	session beginUnitOfWork.
    	addresses := session readManyOf: GlorpEmailAddress.
    	addresses do: [:each | each host: 'bar.org'].
    	self assert: ((session privateGetCache cacheForClass: GlorpPerson) at: 3 ifAbsent: [nil]) isNil.
    	session commitUnitOfWork.
    	addressRows := session accessor executeSQLString: 'SELECT PERSON_ID, HOST_NAME from EMAIL_ADDRESS'.
    	self assert: addressRows size = 2.
    	addressRows do: [:each | 
    		self assert: (each atIndex: 1) = 3.
    		self assert: (each atIndex: 2) = 'bar.org'].
].!

testReadJustTheEmailAddressNotThePersonAndWriteBackWithNoChanges
    | addresses addressRows |
    "We won't have the person object to set a value for the PERSON_ID field. Ensure that we don't write a null for that field, or otherwise modify things."
    self inTransactionDo: [	
    	self writePersonWithEmailAddresses.
    	session beginUnitOfWork.
    	addresses := session readManyOf: GlorpEmailAddress.
    	self assert: ((session privateGetCache cacheForClass: GlorpPerson) at: 3 ifAbsent: [nil]) isNil.
    	session commitUnitOfWork.
    	addressRows := session accessor executeSQLString: 'SELECT PERSON_ID from EMAIL_ADDRESS'.
    	self assert: addressRows size = 2.
    	addressRows do: [:each | self assert: (each atIndex: 1) = 3].
].!

testReadPersonAndAddEmailAddress
    | |
    self
    	inTransactionDo:
    		[
    		self 
    			inUnitOfWorkDo: [person emailAddresses add: (GlorpEmailAddress new id: 99876; user: 'postmaster'; host: 'foo.com')]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId3 := 99876.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses].!

testReadPersonAndDeleteEmailAddress
    self
    	inTransactionDo:
    		[
    		self 
    			inUnitOfWorkDo: [
    				session delete: person emailAddresses last. 
    				person emailAddresses removeLast. ]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId2 := nil.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses.
    		self checkNumberOfEmailAddressesInDB: 1].!

testReadPersonAndRemoveEmailAddress
    self
    	inTransactionDo:
    		[
    		self 
    			inUnitOfWorkDo: [person emailAddresses removeLast]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId2 := nil.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses.
    		self checkNumberOfEmailAddressesInDB: 2].!

testReadPersonAndReplaceEmailAddressesWithDifferent
    | |
    self
    	inTransactionDo:
    		[self 
    			inUnitOfWorkDo: [
    				person emailAddresses: (Array with: (GlorpEmailAddress new id: 99876; user: 'postmaster'; host: 'foo.com')) ]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId1 := 99876.
    		emailId2 := nil.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses.
    		self checkNumberOfEmailAddressesInDB: 3].!

testReadPersonAndReplaceEmailAddressesWithRemoval
    | |
    self
    	inTransactionDo:
    		[self 
    			inUnitOfWorkDo: [
    				person emailAddresses: (Array with: person emailAddresses first) ]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId2 := nil.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses.
    		self checkNumberOfEmailAddressesInDB: 2].!

testReadPersonAndReplaceInstantiatedEmailAddressesWithEmpty
    | |
    self
    	inTransactionDo:
    		[self 
    			inUnitOfWorkDo: [
    				person emailAddresses yourself. 
    				person emailAddresses: #(). ]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId1 := nil.
    		emailId2 := nil.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses.
    		self checkNumberOfEmailAddressesInDB: 2].!

testReadPersonAndReplaceUninstantiatedEmailAddressesWithEmpty
    | |
    self
    	inTransactionDo:
    		[
    		self 
    			inUnitOfWorkDo: [person emailAddresses: #().]
    			initializeWith: [self writePersonWithEmailAddresses].
    		emailId1 := nil.
    		emailId2 := nil.
    		self readPerson.
    		self checkEmailAddresses: person emailAddresses.
    		self checkNumberOfEmailAddressesInDB: 2].!

testReadPersonWithEmailAddresses
    | query result emailAddresses |
    self
    	inTransactionDo:
    		[self writePersonWithEmailAddresses.
    		query := Query
    			returningOneOf: GlorpPerson
    			where: [:eachPerson | eachPerson id = personId].
    		result := query executeIn: session.
    		emailAddresses := result emailAddresses getValue.
    		self checkEmailAddresses: emailAddresses].! !

!GlorpOneToManyDBTest methodsFor: 'tests-write'!

testWritePersonWithEmailAddresses
    | newPerson |
    self inTransactionDo: [
    	session beginUnitOfWork.
    	newPerson := GlorpPerson example1.
    	newPerson id: 231.
    	personId := 231.	
    	newPerson emailAddresses: OrderedCollection new.
    	newPerson emailAddresses add: (GlorpEmailAddress new id: 2; user: 'one'; host: 'blorch.ca').
    	newPerson emailAddresses add: (GlorpEmailAddress new id: 3; user: 'two'; host: 'blorch.ca').
    	emailId1 := 2.
    	emailId2 := 3.
    	session register: newPerson.
    	session commitUnitOfWork.
    	session reset.
    	self readPerson.
    	self checkEmailAddresses: person emailAddresses.
    	self checkNumberOfEmailAddressesInDB: 2].!

testWritePersonWithNoEmailAddresses
    | newPerson |
    self inTransactionDo: [
    	session beginUnitOfWork.
    	newPerson := GlorpPerson new.
    	newPerson id: 231.
    	personId := 231.
    	session register: newPerson.
    	session commitUnitOfWork.
    	session reset.
    	self readPerson.
    	self assert: person emailAddresses isEmpty.
    	self checkNumberOfEmailAddressesInDB: 0].!

testWritePersonWithNoEmailAddresses2
    | newPerson |
    self inTransactionDo: [
    	session beginUnitOfWork.
    	newPerson := GlorpPerson new.
    	newPerson id: 231.
    	personId := 231.
    	newPerson emailAddresses: OrderedCollection new.
    	session register: newPerson.
    	session commitUnitOfWork.
    	session reset.
    	self readPerson.
    	self assert: person emailAddresses isEmpty.
    	self checkNumberOfEmailAddressesInDB: 0].! !

!GlorpOneToManyDBTest methodsFor: 'tests-join'!

setUpSomeExtraPeople
    self
    	inUnitOfWorkDo:
    		[| otherPerson |
    		session register: (GlorpPerson new id: 9924365).
    		otherPerson := GlorpPerson new id: 12121.
    		otherPerson
    			emailAddresses:
    				(OrderedCollection
    					with:
    						((GlorpEmailAddress new)
    							id: 7;
    							host: 'asdfasdf')).
    		session register: otherPerson]
    	initializeWith: [self writePersonWithEmailAddresses].!

testReadPersonWithJoinToEmailAddresses
    | people |
    self
    	inTransactionDo:
    		[self setUpSomeExtraPeople.
    		people := session
    			readManyOf: GlorpPerson
    			where:
    				[:eachPerson | 
    				eachPerson emailAddresses
    					anySatisfy: [:eachEmail | eachEmail host = 'objectpeople.com']].
    		self assert: people size = 1].!

testReadPersonWithNegativeJoinToEmailAddresses
    "Read with a negative condition. Note that this excludes the person with no e-mail addresses, as we're not doing an outer join"
    | people |
    self
    	inTransactionDo:
    		[self setUpSomeExtraPeople.
    		people := session
    			readManyOf: GlorpPerson
    			where:
    				[:eachPerson | 
    				eachPerson emailAddresses
    					anySatisfy: [:eachEmail | eachEmail host ~= 'objectpeople.com']].
    		self assert: people size = 2].! !

!GlorpOneToManyDBTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseTableTest methodsFor: 'tests'!

testFKUniqueNames
    | platform contactTable linkTable companyId personId |
    platform := GlorpDatabaseLoginResource defaultPlatform.
    contactTable := DatabaseTable new
    					name: 'CONTACT';
    					yourself.
    contactTable createFieldNamed: 'ID' type: platform serial.

    linkTable := DatabaseTable new
    					name: 'COMPANY_PERSON_LINK';
    					yourself.
    companyId := linkTable createFieldNamed: 'COMPANY_ID' type: platform int4.
    personId := linkTable createFieldNamed: 'PERSON_ID' type: platform int4.
    linkTable
    	addForeignKeyFrom: companyId to: (contactTable fieldNamed: 'ID');
    	addForeignKeyFrom: personId to: (contactTable fieldNamed: 'ID').
    self assert: (linkTable foreignKeyConstraints collect: [:ea | ea name asSymbol]) asSet size = linkTable foreignKeyConstraints size.! !

!GlorpDatabaseTableTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseTypeTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpWorker methodsFor: 'initialize/release'!

initialize
    pendingJobs := OrderedCollection new.
    finishedJobs := OrderedCollection new.
    priorityJobs := OrderedCollection new.! !

!GlorpWorker methodsFor: 'accessing'!

finishedJobs
    ^finishedJobs!

finishedJobs: anObject
    finishedJobs := anObject!

id
    ^id!

id: anObject
    id := anObject!

name
    ^name!

name: anObject
    name := anObject!

pendingJobs
    ^pendingJobs!

pendingJobs: anObject
    pendingJobs := anObject!

priorityJobs
    ^priorityJobs!

priorityJobs: anObject
    priorityJobs := anObject! !

!GlorpWorker class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpWorker class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpBasicMappingTest methodsFor: 'tests'!

testGet
    
    self assert: (mapping getValueFrom: person) = 1!

testSet
    
    mapping setValueIn: person to: 2.
    self assert: person id = 2.
    self assert: (mapping getValueFrom: person) = 2.! !

!GlorpBasicMappingTest methodsFor: 'support'!

setUp
    super setUp.
    mapping := DirectMapping new.
    mapping attributeName: #id.
    person := GlorpPerson example1.! !

!GlorpBasicMappingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpOffice methodsFor: 'accessing'!

addEmployee: anEmployee
    self employees add: anEmployee.!

employeeOfMonth
    ^employeeOfMonth!

employeeOfMonth: anObject
    employeeOfMonth := anObject!

employees
    employees isNil ifTrue: [ employees := OrderedCollection new ].
    ^employees!

employees: anObject
    employees := anObject!

id
    ^id!

id: anObject
    id := anObject!

street
    ^street!

street: aString
    street := aString! !

!GlorpOffice class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpConstantMappingTest methodsFor: 'tests'!

testConstantInClass
    slot := nil.
    mappingToClass mapObject: self inElementBuilder: nil.
    self assert: slot = 34.!

testConstantInClassDoesNotWriteToRow
    "Would raise an exception if it tried to write into nil"
    mappingToClass mapFromObject: self intoRowsIn: nil.!

testGetValue
    slot := nil.
    self assert: (mappingToClass getValueFrom: self) = 34.!

testSessionValue
    mappingToClass constantValueIsSession.
    self assert: (mappingToClass constantValueIn: 38)== 38.! !

!GlorpConstantMappingTest methodsFor: 'support'!

setUp
    super setUp.
    mappingToClass := ConstantMapping new
    	attributeName: #slot;
    	constantValue: 34.
    mappingToRow := ConstantMapping new.
    mappingToSession := ConstantMapping new! !

!GlorpConstantMappingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpCompressedMoney methodsFor: 'accessing'!

amount
    ^array at: 2!

amount: anObject
    array at: 2 put: anObject!

currency
    ^array at: 1!

currency: anObject
    array at: 1 put: anObject! !

!GlorpCompressedMoney methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream
    	nextPut: $(;
    	print: self amount;
    	space;
    	nextPutAll: self currency;
    	nextPut: $).! !

!GlorpCompressedMoney methodsFor: 'initialize'!

initialize
    array := Array new: 2.! !

!GlorpCompressedMoney class methodsFor: 'instance creation'!

currency: aSymbol amount: aNumber
    ^super new initialize
    	currency: aSymbol;
    	amount: aNumber.!

defaultCurrency
    ^#CDN.!

forAmount: aNumber
    ^self currency: self defaultCurrency amount: aNumber.! !

!GlorpCompressedMoney class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpThingOne methodsFor: 'accessing'!

id
    ^id!

id: anInteger
    id := anInteger!

name
    ^name!

name: aString
    name := aString! !

!GlorpThingOne methodsFor: 'comparing'!

<= aThingOne
    ^self name <= aThingOne name.! !

!GlorpThingOne class methodsFor: 'instance creation'!

named: aString
    ^self new name: aString.! !

!GlorpMoney methodsFor: 'accessing'!

amount
    ^amount!

amount: anInteger
    amount := anInteger!

currency
    ^currency!

currency: aSymbol
    currency := aSymbol! !

!GlorpMoney class methodsFor: 'instance creation'!

currency: aSymbol amount: aNumber
    ^self new
    	currency: aSymbol;
    	amount: aNumber.!

defaultCurrency
    ^#CDN.!

forAmount: anAmount
    ^self currency: self defaultCurrency amount: anAmount.! !

!GlorpMoney class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseLoginTest methodsFor: 'tests'!

testLogin
    self assert: self accessor isLoggedIn not.
    self accessor login.
    self assert: self accessor isLoggedIn.
    self accessor logout.
    self assert: self accessor isLoggedIn not!

testUnsuccessfulLogin
    | anotherAccessor invalidLogin |

    invalidLogin := GlorpDatabaseLoginResource defaultLogin copy.
    invalidLogin
    	password: 'you will never ever guess this password';
    	username: 'not a valid user name'.
    anotherAccessor := DatabaseAccessor forLogin: invalidLogin.

    self assert: anotherAccessor isLoggedIn not.
    anotherAccessor loginIfError: [:ex | ].
    Dialect isVisualAge ifFalse: [ "The isLoggedIn is unreliable under VA, can return false positive"
    	self assert: anotherAccessor isLoggedIn not].
    anotherAccessor logout.! !

!GlorpDatabaseLoginTest methodsFor: 'accessing'!

accessor
    ^accessor.! !

!GlorpDatabaseLoginTest methodsFor: 'support'!

setUp
    super setUp.
    login := GlorpDatabaseLoginResource defaultLogin.
    accessor := DatabaseAccessor forLogin: login.! !

!GlorpDatabaseLoginTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource.! !

!GlorpDatabaseLoginTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseSessionTest methodsFor: 'tests'!

testWriteRow
    | rowToWrite fields rowReadFromDatabase |
    rowToWrite := session system examplePersonRow2.
    
    [session beginTransaction.
    session writeRow: rowToWrite.
    rowReadFromDatabase := (session accessor
    			executeSQLString: 'SELECT * FROM ' , rowToWrite table name) first.
    fields := rowToWrite table fields.
    (1 to: fields size) with: fields
    	do: [:index :field | self assert: (rowReadFromDatabase atIndex: index) = (rowToWrite at: field)]] 
    		ensure: [session rollbackTransaction]! !

!GlorpDatabaseSessionTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpDatabaseSessionTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpDatabaseSessionTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpQueryStub methodsFor: 'executing'!

executeWithParameters: parameterArray in: aSession 
    aSession register: result.
    ^result.! !

!GlorpQueryStub methodsFor: 'initialize'!

initialize
    super initialize.
    readsOneObject := true.! !

!GlorpQueryStub methodsFor: 'accessing'!

result
    ^result!

result: anObject
    result := anObject! !

!GlorpQueryStub class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpCoreExtensionstest methodsFor: 'tests'!

testGlorpIsCollection
    self deny: Object new glorpIsCollection.
    self assert: Collection new glorpIsCollection! !

!GlorpCoreExtensionstest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpBankAccount methodsFor: 'comparing'!

<= anAccount
    ^self accountNumber accountNumber <= anAccount accountNumber accountNumber.! !

!GlorpBankAccount methodsFor: 'accessing'!

accountHolders
    ^accountHolders.!

accountNumber
    ^accountNumber!

accountNumber: anAccountNumber 
    accountNumber := anAccountNumber!

basicAddHolder: aCustomer
    accountHolders add: aCustomer.!

basicRemoveHolder: aCustomer
    accountHolders remove: aCustomer.!

id
    ^id!

id: anObject
    id := anObject! !

!GlorpBankAccount methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream 
    	nextPutAll: '(id=';
    	print: id;
    	nextPut: $).! !

!GlorpBankAccount methodsFor: 'initialize'!

initialize
    accountHolders := OrderedCollection new.! !

!GlorpBankAccount class methodsFor: 'examples'!

example1
    ^self new 
    	id: 123;
    	accountNumber: GlorpBankAccountNumber example12345.! !

!GlorpBankAccount class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpBankAccount class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpBankTransaction methodsFor: 'accessing'!

amount
    ^amount!

amount: aGlorpMoney 
    amount := aGlorpMoney!

id
    "Private - Answer the value of the receiver's ''id'' instance variable."

    ^id!

id: anObject
    "Private - Set the value of the receiver's ''id'' instance variable to the argument, anObject."

    id := anObject!

owner
    "Private - Answer the value of the receiver's ''owner'' instance variable."

    ^owner!

owner: aCustomer 
    owner := aCustomer!

serviceCharge
    ^serviceCharge!

serviceCharge: aServiceCharge 
    serviceCharge := aServiceCharge! !

!GlorpBankTransaction methodsFor: 'initialize'!

initialize
    amount := GlorpMoney forAmount: 0.
    serviceCharge := GlorpServiceCharge default.! !

!GlorpBankTransaction class methodsFor: 'examples'!

example1
    ^self new!

example2
    ^self new! !

!GlorpBankTransaction class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpBankTransaction class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpReadingDifferentCollectionsTest methodsFor: 'setup'!

setUp
    
    | |
    super setUp.
    session := GlorpSessionResource current newSession.
    system := session system.
    session beginTransaction.
    self writeAccountRows.
    singleQuery := Query returningManyOf: GlorpBankAccount
    			where: [:passenger | passenger id = 6].
    allQuery := Query returningManyOf: GlorpBankAccount.!

tearDown
    session rollbackTransaction.!

writeAccountRows
    | accountRow1 accountRow2 |

    accountRow1 := session system exampleAccountRow1. 
    accountRow2 := session system exampleAccountRow2.
    session writeRow: accountRow1.
    session writeRow: accountRow2.! !

!GlorpReadingDifferentCollectionsTest methodsFor: 'tests'!

check: aClass
    singleQuery collectionType: aClass.
    allQuery collectionType: aClass.
    singleResult := session execute: singleQuery.
    allResult := session execute: allQuery.
    self assert: singleResult class == aClass.
    self assert: allResult class == aClass.
    self assert: singleResult size = 1.
    self assert: allResult size = 2.!

testArray
    self check: Array.!

testBlank
    singleResult := session execute: singleQuery.
    allResult := session execute: allQuery.
    self assert: singleResult class == Array.
    self assert: allResult class == Array.
    self assert: singleResult size = 1.
    self assert: allResult size = 2.!

testOrderedCollection
    self check: OrderedCollection.!

testSet
    self check: Set.!

testSortedCollection
    self check: SortedCollection.! !

!GlorpObjectWithNoAccessors methodsFor: 'accessing'!

value_: aString
    value := aString! !

!GlorpObjectWithNoAccessors class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpressionIterationTest methodsFor: 'tests'!

helpTestSingleNodeDo: exp 
    self assert: (exp collect: [:each | each]) = (OrderedCollection with: exp)!

testDoBase
    self helpTestSingleNodeDo:BaseExpression new!

testDoCollection
    | exp l r |
    exp := CollectionExpression new.
    l := BaseExpression new.
    r := BaseExpression new.
    exp leftChild: l; rightChild: r.
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: l with: r with: exp)).!

testDoConstant
    self helpTestSingleNodeDo: ConstantExpression new!

testDoField
    | exp |
    exp := FieldExpression new.
    exp field: nil base: BaseExpression new.
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: exp base with: exp)).!

testDoMapping
    | exp |
    exp := MappingExpression new.
    exp named: 'foo' basedOn: BaseExpression new.
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: exp base with: exp)).!

testDoParameter
    | exp |
    exp := ParameterExpression new.
    exp field: nil base: BaseExpression new.
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: exp base with: exp)).!

testDoRelation
    | exp l r |
    exp := RelationExpression new.
    l := BaseExpression new.
    r := BaseExpression new.
    exp leftChild: l; rightChild: r.
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: l with: r with: exp)).!

testDoTable
    | exp |
    exp := TableExpression new.
    exp table: nil base: BaseExpression new.
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: exp base with: exp)).!

testDoWithCommonBase
    | exp l r base |
    exp := RelationExpression new.
    base := BaseExpression new.
    l := MappingExpression new.
    l named: nil basedOn: base.
    r := MappingExpression new.
    r named: nil basedOn: base.
    exp leftChild: l; rightChild: r.	
    self assert: ((exp collect: [:each | each]) = (OrderedCollection with: base with: l with: r with: exp)).! !

!GlorpExpressionIterationTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseLoginResource methodsFor: 'accessing'!

accessor
    ^accessor!

accessor: anObject
    accessor := anObject!

login
    ^login!

login: anObject
    login := anObject!

platform
    ^login database! !

!GlorpDatabaseLoginResource methodsFor: 'initialize/release'!

setUp
    Transcript show: self class name asString, ' setUp'; nl.
    super setUp.
    login := self class defaultLogin.
    accessor := DatabaseAccessor forLogin: login.
    accessor login.!

tearDown
    Transcript show: self class name asString, ' tearDown'; nl.
    accessor notNil ifTrue: [[accessor logout] on: Error do: [:ex | ]].! !

!GlorpDatabaseLoginResource class methodsFor: 'accessing'!

constructEventsTriggered
    ^(super constructEventsTriggered)
    	add: #changedDefaultLogin;
    	yourself!

defaultLogin
    "Return the default Login."

    DefaultLogin isNil ifTrue: [^DefaultLogin := self defaultMysqlLogin].
    ^DefaultLogin!

defaultLogin: aLogin 
    DefaultLogin := aLogin.
    self triggerEvent: #changedDefaultLogin!

defaultPlatform
    ^self defaultLogin database class new!

defaultMysqlLogin
    "To set the default database login to MySQL, execute the following statement."
    "DefaultLogin := self defaultMysqlLogin."

    ^(Login new)
    	database: MySQLPlatform new;
    	username: 'root';
    	password: 'root';
    	connectString: 'test'.! !

!GlorpDatabaseLoginResource class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseBasedTest methodsFor: 'support'!

setUp
    system := GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database.
    system session: GlorpMockSession new.
    system session system: system.! !

!GlorpDatabaseBasedTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPrimaryKeyExpressionWithConstantTest methodsFor: 'tests'!

testAsExpressionCompound
    
    | e personTable |
    personTable := system tableNamed: 'PERSON'.

    e := compoundExpression asGeneralGlorpExpression.
    self assert: (e rightChild isKindOf: RelationExpression).
    self assert: (e rightChild relation == #=).
    self assert: (e rightChild leftChild isKindOf: FieldExpression).
    self assert: e rightChild leftChild field == (personTable fieldNamed: 'ADDRESS_ID').
    self assert: (e rightChild rightChild isKindOf: ConstantExpression).
    self assert: e rightChild rightChild value = 'B'.!

testAsExpressionSingle
    
    | e field param |
    e := expression asGeneralGlorpExpression.
    self assert: (e isKindOf: RelationExpression).
    self assert: e relation == #=.
    field := e leftChild.
    self assert: (field isKindOf: FieldExpression).
    self assert: field field == ((system tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'ACCT_ID').
    param := e rightChild.
    self assert: (param isKindOf: ConstantExpression).
    self assert: param value = 7.!

testCompoundSQLPrinting
    | stream params|
    stream := WriteStream on: (String new: 100).
    params := Dictionary new.
    params at: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID') put: 1.
    compoundExpression printSQLOn: stream withParameters: params.
    self assert: stream contents = 'PERSON.NAME = 1 AND PERSON.ADDRESS_ID = ''B'''.!

testParameterCount
    self assert: expression numberOfParameters = 1.
    self assert: compoundExpression numberOfParameters = 2.!

testSQLPrinting
    | stream params |
    stream := WriteStream on: (String new: 100).
    params := Dictionary new.
    expression printSQLOn: stream withParameters: params.
    self assert: stream contents = 'CUSTOMER_ACCT_LINK.ACCT_ID = 7'! !

!GlorpPrimaryKeyExpressionWithConstantTest methodsFor: 'support'!

setUp
    super setUp.
    expression := Join 
    	from: 7
    	to: ((system tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'ACCT_ID').

    compoundExpression := Join
    	from: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID')
    	to: ((system tableNamed: 'PERSON') fieldNamed: 'NAME').
    compoundExpression
    	addSource: 'B'
    	target: ((system tableNamed: 'PERSON') fieldNamed: 'ADDRESS_ID').! !

!GlorpPrimaryKeyExpressionWithConstantTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPrimaryKeyExpressionTest methodsFor: 'tests'!

testAsExpressionCompound
    
    | e personTable accountTable |
    personTable := system tableNamed: 'PERSON'.
    accountTable := system tableNamed: 'BANK_ACCT'.

    e := compoundExpression asGeneralGlorpExpression.
    self assert: (e isKindOf: RelationExpression).
    self assert: e relation == #AND.
    self assert: (e leftChild isKindOf: RelationExpression).
    self assert: (e leftChild relation == #=).
    self assert: (e leftChild leftChild isKindOf: FieldExpression).
    self assert: e leftChild leftChild field == (personTable fieldNamed: 'NAME').
    self assert: (e leftChild rightChild isKindOf: ParameterExpression).
    self assert: e leftChild rightChild field == (accountTable fieldNamed: 'ID').


    self assert: (e rightChild isKindOf: RelationExpression).
    self assert: (e rightChild relation == #=).
    self assert: (e rightChild leftChild isKindOf: FieldExpression).
    self assert: e rightChild leftChild field == (personTable fieldNamed: 'ADDRESS_ID').
    self assert: (e rightChild rightChild isKindOf: ParameterExpression).
    self assert: e rightChild rightChild field = (accountTable fieldNamed: 'BANK_CODE').!

testAsExpressionSingle
    
    | e field param |
    e := expression asGeneralGlorpExpression.
    self assert: (e isKindOf: RelationExpression).
    self assert: e relation == #=.
    field := e leftChild.
    self assert: (field isKindOf: FieldExpression).
    self assert: field field == ((system tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'ACCT_ID').
    param := e rightChild.
    self assert: (param isKindOf: ParameterExpression).
    self assert: param field == ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID').!

testCompoundSQLPrinting
    | stream params|
    stream := WriteStream on: (String new: 100).
    params := Dictionary new.
    params at: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID') put: 1.
    params at: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'BANK_CODE') put: 3.
    compoundExpression printSQLOn: stream withParameters: params.
    self assert: stream contents = 'PERSON.NAME = 1 AND PERSON.ADDRESS_ID = 3'.!

testCreation
    self assert: expression allSourceFields size = 1.
    self assert: expression allSourceFields first == ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID').!

testParameterCount
    self assert: expression numberOfParameters = 1.
    self assert: compoundExpression numberOfParameters = 2.!

testSQLPrinting
    | stream params |
    stream := WriteStream on: (String new: 100).
    params := Dictionary new.
    params at: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID') put: 'abc'.
    expression printSQLOn: stream withParameters: params.
    self assert: stream contents = 'CUSTOMER_ACCT_LINK.ACCT_ID = ''abc'''! !

!GlorpPrimaryKeyExpressionTest methodsFor: 'support'!

setUp
    super setUp.
    expression := Join 
    	from: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID')
    	to: ((system tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'ACCT_ID').

    compoundExpression := Join
    	from: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'ID')
    	to: ((system tableNamed: 'PERSON') fieldNamed: 'NAME').
    compoundExpression
    	addSource: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'BANK_CODE')
    	target: ((system tableNamed: 'PERSON') fieldNamed: 'ADDRESS_ID').! !

!GlorpPrimaryKeyExpressionTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpSessionTest methodsFor: 'support'!

addCustomerToCache
    | customer |
    customer := GlorpCustomer example1.
    customer id: 3.
    session cacheAt: 3 put: customer.
    ^customer!

setUp
    super setUp.
    session := GlorpSession new.
    session system: system! !

!GlorpSessionTest methodsFor: 'tests'!

testAddingDescriptors
    self assert: session system == system.
    self assert: system session == session.
    (session descriptorFor: GlorpAddress) session == session.!

testExecuteQuery
    | q result |
    q := GlorpQueryStub new result: 3.
    result := session execute: q.
    self assert: result = 3!

testHasExpired1
    | customer |
    customer := self addCustomerToCache.
    self deny: (session hasExpired: customer)!

testHasExpired2
    | customer |
    (session system descriptorFor: GlorpCustomer) 
    	cachePolicy: (TimedExpiryCachePolicy new timeout: 0).
    customer := self addCustomerToCache.
    self assert: (session hasExpired: customer)!

testHasObjectOfClassExpired1
    self addCustomerToCache.
    self deny: (session hasObjectExpiredOfClass: GlorpCustomer withKey: 3).!

testHasObjectOfClassExpired2
    (session system descriptorFor: GlorpCustomer) 
    	cachePolicy: (TimedExpiryCachePolicy new timeout: 0).
    self addCustomerToCache.
    self assert: (session hasObjectExpiredOfClass: GlorpCustomer withKey: 3).!

testSQLDeleteStringFor
    | row table string |
    table := session system tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'ID') put: 12.
    row at: (table fieldNamed: 'STREET') put: 'some street'.
    string := (DeleteCommand forRow: row useBinding: true platform: session system platform) sqlString.
    self assert: string = 'DELETE FROM GR_ADDRESS WHERE ID = ?'.
    string := (DeleteCommand forRow: row useBinding: false platform: session system platform) sqlString.
    self assert: string = 'DELETE FROM GR_ADDRESS WHERE ID = 12'.!

testUpdateWithExpiredExistingEntry
    | customer customer2 row table unitOfWork |
    (session system descriptorFor: GlorpCustomer) 
    	cachePolicy: (TimedExpiryCachePolicy new timeout: 0; expiryAction: #refresh).
    customer := self addCustomerToCache.
    customer2 := GlorpCustomer new.
    customer2 id: customer id.
    customer2 name: 'Barney Rubble'.
    row := DatabaseRow newForTable: (table := system tableNamed: 'GR_CUSTOMER').
    row at: (table fieldNamed: 'ID') put: customer id.
    unitOfWork := UnitOfWork new.
    unitOfWork session: session.
    "Since there's already an object there, this shouldn't do anything"
    unitOfWork updateSessionCacheFor: customer2 withRow: row.
    self assert: (session expiredInstanceOf: GlorpCustomer key: 3) == customer.!

testUpdateWithoutExpiredExistingEntry
    | customer2 row table unitOfWork |
    (session system descriptorFor: GlorpCustomer) 
    	cachePolicy: (TimedExpiryCachePolicy new timeout: 0).
    customer2 := GlorpCustomer new.
    customer2 id: 3.
    customer2 name: 'Barney Rubble'.
    row := DatabaseRow newForTable: (table := system tableNamed: 'GR_CUSTOMER').
    row at: (table fieldNamed: 'ID') put: 3.
    unitOfWork := UnitOfWork new.
    unitOfWork session: session.
    unitOfWork updateSessionCacheFor: customer2 withRow: row.
    self assert: (session expiredInstanceOf: GlorpCustomer key: 3) == customer2.! !

!GlorpSessionTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpressionJoiningTest methodsFor: 'tests'!

join: exp 
    ^exp asExpressionJoiningSource: source toTarget: target!

resultOfJoiningFieldFor: aTable toExpressionBuiltOn: anotherTable
    | exp table |
    base descriptor: (system descriptorFor: GlorpCustomer).
    exp := FieldExpression forField: (aTable fieldNamed: 'ID')
    			basedOn: BaseExpression new.
    table := base getTable: anotherTable.

    ^exp asExpressionJoiningSource: base toTarget: table.!

testBase
    | result |
    result := self join: base. 
    self assert: result == source.!

testConstant
    | exp |
    exp := ConstantExpression for: 42.
    self assert: (self join: exp) == exp!

testField
    | exp  result |
    exp := FieldExpression forField: (DatabaseField named: 'test' type: system platform int4)
    			basedOn: base.
    result := self join: exp.
    self assert: result base == source.
    self assert: result field == exp field!

testFieldBuiltOnDifferentTable
    | result custTable |
    custTable := system tableNamed: 'GR_CUSTOMER'.
    result := self 
    	resultOfJoiningFieldFor: custTable
    	toExpressionBuiltOn: custTable.
    self assert: result base == (base getTable: custTable).
    self assert: result field == ((system tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID').!

testFieldBuiltOnSameTable
    | exp result base2 table custTable |
    custTable := system tableNamed: 'GR_CUSTOMER'.
    base2 := BaseExpression new.
    base2 descriptor: (system descriptorFor: GlorpCustomer).
    table := base2 getTable: custTable.
    exp := FieldExpression forField: (custTable fieldNamed: 'ID')
    			basedOn: base.
    result := exp asExpressionJoiningSource: base2 toTarget: table.
    self assert: result base == table.
    self assert: result field == exp field.!

testMapping
    | result exp |
    exp := base get: #foo.
    result := self join: exp. 
    self assert: result base == source.
    self assert: result name = #foo.!

testParameter
    | result exp table field |
    table := DatabaseTable named: 'T'.	
    field := DatabaseField named: 'F' type: system platform int4.
    table addField: field.
    exp := base getParameter: field.
    result := self join: exp.
    self assert: result base == source.
    self assert: result class == FieldExpression.
    self assert: result field == field.!

testRelation
    | result exp |
    exp := [:a | a foo = 3] asGlorpExpressionOn: base.
    result := self join: exp. 

    self assert: result class == RelationExpression.
    self assert: result rightChild == exp rightChild.
    self assert: result leftChild base == source.!

testRelation2
    | result exp field | 
    field := DatabaseField named: 'fred' type: system platform int4.
    exp := [:a | a foo = field] asGlorpExpressionOn: base.
    result := self join: exp. 
    self assert: result class == RelationExpression.
    self assert: result rightChild class == FieldExpression.
    self assert: result rightChild field == field.
    self assert: result leftChild base == source.!

testSelfJoinWithPrimaryKeyExpression
    "This tests a join of a class to itself, in this case customers who have other customers associated with them. Useful for hierarchies"
    | pkExpression field result |
    field := (system tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID'.
    pkExpression := Join 
    	from: field
    	to: field.
    result := self join: pkExpression.
    self assert: result leftChild basicField == field.
    self assert: result rightChild basicField == field.
    self assert: result rightChild base name = #relation.!

testTable
    | result exp table |
    table := DatabaseTable named: 'T'.
    exp := base getTable: table.
    result := self join: exp. 
    self assert: result base == target.
    self assert: result table == table.! !

!GlorpExpressionJoiningTest methodsFor: 'support'!

setUp
    super setUp.
    source := BaseExpression new.
    target := source get: #relation.
    base := BaseExpression new.!

tearDown
    source := nil.
    target := nil.
    base := nil.
    system := nil.! !

!GlorpExpressionJoiningTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDirectMappingTest methodsFor: 'tests'!

testExpressionFor
    | cust exp |
    cust := GlorpCustomer new.
    cust id: 12.
    exp := mapping expressionFor: cust.
    self assert: exp rightChild class == ConstantExpression.
    self assert: exp rightChild value = 12.
    self assert: exp relation = #=.
    self assert: exp leftChild class == FieldExpression.! !

!GlorpDirectMappingTest methodsFor: 'support'!

setUp
    super setUp.
    mapping := DirectMapping from: #id to: ((system tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID')! !

!GlorpDirectMappingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpRowDifferencingTest methodsFor: 'tests'!

computeDifference
    currentObjectRowMap := self generateRowMapFor: currentObject.
    correspondenceMap := self correspond: currentObject to: mementoObject.
    mementoObjectRowMap := self generateMementoRowMapFor: mementoObject withCorrespondenceMap: correspondenceMap.
    differenceMap := currentObjectRowMap differenceFrom: mementoObjectRowMap.!

testDifferenceFromAnotherObject
    currentObject := GlorpPerson example1.
    mementoObject := GlorpPerson example2.
    self computeDifference.
    self assert: differenceMap numberOfEntries = 2.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'PERSON')) = 1.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'GR_ADDRESS')) = 1!

testDifferenceFromSameObjectWithAddedComponent
"	Commenting these out because I think the setup is just wrong.
currentObject := Person example1.
    mementoObject := Person example1WithNoAddress.
    self computeDifference.
    self assert: differenceMap numberOfEntries = 2.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'PERSON')) = 1.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'GR_ADDRESS')) = 1"!

testDifferenceFromSameObjectWithChangedAttribute
    currentObject := GlorpPerson example1.
    mementoObject := GlorpPerson example1WithDifferentName.
    self computeDifference.
    self assert: differenceMap numberOfEntries = 1.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'PERSON')) = 1!

testDifferenceFromSameObjectWithChangedComponent
    "Commenting these out because I think the setup is just wrong"
    "currentObject := Person example1.
    mementoObject := Person example1WithDifferentAddress.

    currentObjectRowMap := self generateRowMapFor: currentObject."

    "Before changes occur, all original objects are registered with the unit of work.  
    	To mimic that, the original person's address needs to be added to current (after changes) "
"	self addRowsFor: mementoObject address to: currentObjectRowMap.
    correspondenceMap := self correspond: currentObject to: mementoObject.
    correspondenceMap at: mementoObject address put: mementoObject address.
    correspondenceMap removeKey: currentObject address.
    mementoObjectRowMap := self generateMementoRowMapFor: mementoObject withCorrespondenceMap: correspondenceMap.
    differenceMap := currentObjectRowMap differenceFrom: mementoObjectRowMap.
    self assert: differenceMap numberOfEntries = 2.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'PERSON')) = 1.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'GR_ADDRESS')) = 1"!

testDifferenceFromSameObjectWithChangedComponentAttribute
    currentObject := GlorpPerson example1.
    mementoObject := GlorpPerson example1WithChangedAddress.
    self computeDifference.
    self assert: differenceMap numberOfEntries = 1.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'GR_ADDRESS')) = 1!

testDifferenceFromSameObjectWithDeletedComponent
    "Commenting these out because I think the setup is just wrong"
"	currentObject := Person example1WithNoAddress.
    mementoObject := Person example1.
    self computeDifference.
    self assert: differenceMap numberOfEntries = 1.
    self 
    	assert: (differenceMap 
    			numberOfEntriesForTable: (system tableNamed: 'PERSON')) = 1"!

testEquality
    | addressRow1 addressRow2 |
    addressRow1 := session system exampleAddressRow.
    addressRow2 := session system exampleAddressRowWithDifferentStreet.
    self assert: (addressRow1 equals: addressRow1).
    self assert: (addressRow1 equals: addressRow2) not.!

testNoDifference2
    | |
    currentObject := GlorpPerson example1.
    mementoObject := GlorpPerson example1.
    self computeDifference.
    self assert: differenceMap numberOfEntries = 0.! !

!GlorpRowDifferencingTest methodsFor: 'support'!

addRowsFor: object to: rowMap 
    | descriptor |
    descriptor := system descriptorFor: object class.
    descriptor createRowsFor: object in: rowMap.!

correspond: person1 to: person2 
    | correspondanceMap |
    correspondanceMap := IdentityDictionary new.
    correspondanceMap at: person1 put: person2.
    person1 address notNil ifTrue: 
    	[correspondanceMap at: person1 address put: person2 address.
    	"Now fix it up so this actually looks like a real memento"
    	person2 address: person1 address].
    ^correspondanceMap!

generateMementoRowMapFor: person withCorrespondenceMap: aDictionary
    | rowMap |
    rowMap := RowMapForMementos withCorrespondenceMap: aDictionary.
    self addRowsFor: person to: rowMap.
    (person address notNil and: [(aDictionary at: person address ifAbsent: [nil]) notNil]) ifTrue: [self addRowsFor: (aDictionary at: person address) to: rowMap].
    ^rowMap!

generateRowMapFor: person 
    | rowMap |
    rowMap := RowMap new.
    self addRowsFor: person to: rowMap.
    person address notNil ifTrue: [self addRowsFor: person address to: rowMap].
    ^rowMap!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    system := session system.
    session beginUnitOfWork.! !

!GlorpRowDifferencingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPartialWritesTest methodsFor: 'tests'!

testNoDifferenceNoWrite
self todo!

testWritingNewObject
self todo!

testWritingObjectWithAddedComponent
self todo!

testWritingObjectWithChangedAttribute
self todo!

testWritingObjectWithChangedComponent
self todo!

testWritingObjectWithChangedComponentAttribute
self todo!

testWritingObjectWithDeletedComponent
self todo!

testWritingObjectWithDeletedRelationship
self todo! !

!GlorpPartialWritesTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.! !

!GlorpPartialWritesTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpThingWithLotsOfDifferentCollections methodsFor: 'accessing'!

array
    ^array!

array: anObject
    array := anObject!

bag
    ^bag!

bag: anObject
    bag := anObject!

id
    ^id!

id: anObject
    id := anObject!

name
    ^name!

name: anObject
    name := anObject!

orderedCollection
    ^orderedCollection!

orderedCollection: anObject
    orderedCollection := anObject!

set
    ^set!

set: anObject
    set := anObject!

sortedCollection
    ^sortedCollection!

sortedCollection: anObject
    sortedCollection := anObject! !

!GlorpThingWithLotsOfDifferentCollections methodsFor: 'initialize-release'!

 initialize
    array := #().
    orderedCollection := OrderedCollection new.
    set := Set new.
    bag := Bag new.
    sortedCollection := #() asSortedCollection.! !

!GlorpThingWithLotsOfDifferentCollections class methodsFor: 'instance creation'!

new
    "Answer a newly created and initialized instance."

    ^super new initialize! !

!GlorpThingWithLotsOfDifferentCollections class methodsFor: 'examples'!

example1
    | example array |
    example := self new.
    example name: 'fred'.
    array := Array with: (GlorpThingOne named: 'array1') with: (GlorpThingOne named: 'array2') with: (GlorpThingOne named: 'array3').
    example array: array.
    example set add: (GlorpThingOne named: 'set1').
    example set add: (GlorpThingOne named: 'set2').	
    example orderedCollection add: (GlorpThingOne named: 'orderedCollection1').
    example orderedCollection add: (GlorpThingOne named: 'orderedCollection2').
    example bag add: (GlorpThingOne named: 'bag1').
    example bag add: (GlorpThingOne named: 'bag2').
    example sortedCollection add: (GlorpThingOne named: 'sorted1').
    example sortedCollection add: (GlorpThingOne named: 'sorted2').
    example sortedCollection add: (GlorpThingOne named: 'sorted3').
    example sortedCollection add: (GlorpThingOne named: 'sorted4').
    ^example.!

exampleForOrdering
    | example |
    example := self new.
    example name: 'order'.
    example orderedCollection add: (GlorpThingOne named: 'oc6').
    example orderedCollection add: (GlorpThingOne named: 'oc5').
    example orderedCollection add: (GlorpThingOne named: 'oc4').
    example orderedCollection add: (GlorpThingOne named: 'oc3').
    example orderedCollection add: (GlorpThingOne named: 'oc7').
    example orderedCollection add: (GlorpThingOne named: 'oc8').
    example array: (#('a1' 'a2' 'a3' 'a9' 'a8' 'a7') collect: [:each | GlorpThingOne named: each]).
    ^example! !

!GlorpTracingTest methodsFor: 'tests'!

testAddDuplicateTracings
    | all |
    tracing addExpression: (tracing base get: #foo).
    tracing addExpression: (tracing base get: #foo).
    all := tracing allTracings.
    self assert: all size = 2.
    self assert: all first == tracing base.!

testAddRecursiveTracings
    | all |
    tracing addExpression: (tracing base get: #foo).
    tracing addExpression: ((tracing base get: #foo) get: #bar).
    all := tracing allTracings.
    self assert: all size = 3.
    self assert: all first == tracing base.
    self assert: all last base == (all at: 2).!

testAddTracing
    | all |
    tracing addExpression: (tracing base get: #foo).
    all := tracing allTracings.
    self assert: all size = 2.
    self assert: all first == tracing base.
    self assert: all last == (tracing base get: #foo).!

testAddTwoTracings
    tracing addExpression: (tracing base get: #foo).
    tracing addExpression: (tracing base get: #bar).
    self assert: tracing allTracings size = 3.
    self assert: tracing allTracings first == tracing base.! !

!GlorpTracingTest methodsFor: 'support'!

setUp
    tracing := Tracing new.
    tracing setup.! !

!GlorpTracingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpEncyclopedia methodsFor: 'accessories'!

entries
    ^entries.! !

!GlorpEncyclopedia methodsFor: 'initialize'!

initialize
    entries := Dictionary new.! !

!GlorpEncyclopedia class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpEncyclopedia class methodsFor: 'examples'!

example1
    | result |
    result := GlorpEncyclopedia new.
    result entries at: 'one' put: GlorpEncyclopediaEntry example1.
    result entries at: 'two' put: GlorpEncyclopediaEntry example2.
    ^result.! !

!GlorpEncyclopedia class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpressionBasicPropertiesTest methodsFor: 'tests'!

testHasDescriptorForBase
    | exp |
    self assert: base hasDescriptor.
    exp := [:a | a ] asGlorpExpressionOn: base.
    self assert: exp hasDescriptor.!

testHasDescriptorForDirect
    | exp |
    exp := [:a | a id ] asGlorpExpressionOn: base.
    self deny: exp hasDescriptor.!

testHasDescriptorForOneToMany
    | exp |
    exp := [:a | a emailAddresses ] asGlorpExpressionOn: base.
    self assert: exp hasDescriptor.!

testHasDescriptorForOneToOne
    | exp |
    exp := [:a | a address ] asGlorpExpressionOn: base.
    self assert: exp hasDescriptor.!

testHasDescriptorForPrimaryKeyExpression
    | exp |
    exp := Join new.
    self deny: exp hasDescriptor.!

testHasDescriptorForRelation
    | exp |
    exp := [:a | a = 3] asGlorpExpressionOn: base.
    self deny: exp hasDescriptor.!

testHasDescriptorForTwoLevelDirect
    | exp |
    exp := [:a | a address street] asGlorpExpressionOn: base.
    self deny: exp hasDescriptor.
    self assert: exp base hasDescriptor.!

testHasDescriptorForUninitializedBase
    self deny: BaseExpression new hasDescriptor.! !

!GlorpExpressionBasicPropertiesTest methodsFor: 'support'!

setUp
    base := BaseExpression new descriptor: (
    	(GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database)
    		descriptorFor: GlorpPerson)! !

!GlorpExpressionBasicPropertiesTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpCustomer methodsFor: 'glorp/events'!

glorpNoticeOfExpiryIn: aSession
    seenExpiry := true.!

glorpPostFetch: aSession
    seenPostFetch := true!

glorpPostWrite: aSession
    seenPostWrite := true!

glorpPreWrite: aSession
    seenPreWrite := true!

seenExpiry
    ^seenExpiry! !

!GlorpCustomer methodsFor: 'accessing'!

accounts
    ^accounts.!

accounts: aCollection
    accounts := aCollection.!

addAccount: aBankAccount
    accounts add: aBankAccount.
    aBankAccount basicAddHolder: self.!

addTransaction: aTransaction
    transactions add: aTransaction.
    aTransaction owner: self.!

id
    "Private - Answer the value of the receiver's ''id'' instance variable."

    ^id!

id: anObject
    "Private - Set the value of the receiver's ''id'' instance variable to the argument, anObject."

    id := anObject!

name
    "Private - Answer the value of the receiver's ''name'' instance variable."

    ^name!

name: anObject
    "Private - Set the value of the receiver's ''name'' instance variable to the argument, anObject."

    name := anObject!

removeAccount: aBankAccount
    accounts remove: aBankAccount.
    aBankAccount basicRemoveHolder: self.!

seenPostFetch
    ^seenPostFetch!

seenPostWrite
    ^seenPostWrite!

seenPreWrite
    ^seenPreWrite!

transactions
    "Private - Answer the value of the receiver's ''transactions'' instance variable."

    ^transactions!

transactions: anObject
    "Private - Set the value of the receiver's ''transactions'' instance variable to the argument, anObject."

    transactions := anObject! !

!GlorpCustomer methodsFor: 'As yet unclassified'!

accountsSortedById
    ^accountsSortedById.!

accountsSortedByIdDescending
    ^accountsSortedByIdDescending.! !

!GlorpCustomer methodsFor: 'printing'!

printOn: aStream 
    super printOn: aStream.
    aStream
    	nextPut: $(;
    	print: id;
    	nextPut: $,;
    	nextPutAll: (name ifNil: ['']);
    	nextPutAll: ')'! !

!GlorpCustomer methodsFor: 'initialize/release'!

initialize
    transactions := OrderedCollection new.
    accounts := OrderedCollection new.
    seenExpiry := false.
    seenPostFetch := false.
    seenPreWrite:= false.
    seenPostWrite := false.! !

!GlorpCustomer class methodsFor: 'examples'!

example1
    ^self new
    	name: 'Fred Flintstone';
    	addTransaction: GlorpBankTransaction example1;
    	addTransaction: GlorpBankTransaction example2.!

example2
    ^self new
      id: 123;
    	name: 'Fred Flintstone';
    	addTransaction: GlorpBankTransaction example1;
    	addTransaction: GlorpBankTransaction example2.! !

!GlorpCustomer class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpCustomer class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpCommitOrderTest methodsFor: 'tests'!

testCommitOrder
    | sorter |
    sorter := TableSorter for: (Array with: (system tableNamed: 'BANK_TRANS') with: (system tableNamed: 'GR_CUSTOMER')).
    self assert: sorter sort first name = 'GR_CUSTOMER'.!

testCommitOrder2
    "Test for a cycle between t1 and t2 with t3 also pointing to both. Order of t1, t2 is indeterminate, but t3 should be last"

    | table1 table1id table2 table2id t2fk t3fk t3fk2 sorter t1fk |
    table1 := DatabaseTable new name: 'T1'.
    table1id := (table1 createFieldNamed: 'ID' type: platform inMemorySequence) bePrimaryKey.
    table2 := DatabaseTable new name: 'T2'.
    table2id := (table2 createFieldNamed: 'ID' type: platform inMemorySequence) bePrimaryKey.

    t1fk := table1 createFieldNamed: 'T2_ID' type: platform int4.
    table1 addForeignKeyFrom: t1fk to: table2id.
    t2fk := table2 createFieldNamed: 'T1_ID' type: platform int4.
    table2 addForeignKeyFrom: t2fk to: table1id.

    t3 := DatabaseTable new name: 'T3'.
    t3fk := t3 createFieldNamed: 'T2_ID' type: platform int4.
    t3 addForeignKeyFrom: t3fk to: table2id.
    t3fk2 := t3 createFieldNamed: 'T1_ID' type: platform int4.
    t3 addForeignKeyFrom: t3fk2 to: table1id.

    sorter := TableSorter for: (Array with: t3 with: table2 with: table1).
    self assert: sorter sort last name = 'T3'.!

testCommitOrderNonSequencedFieldsDontCount
    "Test for a cycle between t1 and t2 with t3 also pointing to both, but with nothing sequenced. Order should be completely indeterminate. We rely on the topological sort being predictable and depending on the insert order so that if we feed objects with no dependencies in in different orders we should get different results."

    | t1fk t2fk t3fk t3fk2 sorter sorter2 |
    t1fk := t1 createFieldNamed: 'T2_ID' type: platform int4.
    t1 addForeignKeyFrom: t1fk to: (t2id).
    t2fk := t2 createFieldNamed: 'T1_ID' type: platform int4.
    t2 addForeignKeyFrom: t2fk to: (t1id).

    t3 := DatabaseTable new name: 'T3'.
    t3fk := t3 createFieldNamed: 'T2_ID' type: platform int4.
    t3 addForeignKeyFrom: t3fk to: (t2id).
    t3fk2 := t3 createFieldNamed: 'T1_ID' type: platform int4.
    t3 addForeignKeyFrom: t3fk2 to: (t1id).

    sorter := TableSorter for: (Array with: t3 with: t2 with: t1).
    sorter2 := TableSorter for: (Array with: t1 with: t2 with: t3).
    self assert: sorter sort first ~= sorter2 sort first.! !

!GlorpCommitOrderTest methodsFor: 'support'!

setUp
    super setUp.
    platform := system platform.
    t1 := DatabaseTable new name: 'T1'.
    t1id := (t1 createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    t2 := DatabaseTable new name: 'T2'.
    t2id := (t2 createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    t3 := DatabaseTable new name: 'T3'.
    t3id := (t3 createFieldNamed: 'ID' type: platform int4) bePrimaryKey.! !

!GlorpCommitOrderTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpOneToOneDBTest methodsFor: 'tests-read'!

additionalTests
    "It would be good to have tests here for a foreign key 'pointing' the other direction. Also composite keys (once those work)"!

testReadPersonAndAddAddress
    self inTransactionDo: [
    	self 
    		inUnitOfWorkDo: [person address: (GlorpAddress new id: 5555; street: 'hello'; number: 'world')]
    		initializeWith: [self writeHomelessPerson].
    	self readPerson.
    	self checkPerson].!

testReadPersonAndRemoveAddress
    self inTransactionDo: [
    	self inUnitOfWorkDo: [
    		session delete: person address.
    		person address: nil.].
    	self readPerson.
    	self checkPerson.
    	self checkNoAddress.
    	self checkNoAddressesInDB].!

testReadPersonAndReplaceAddress
    self inTransactionDo:
    	[self inUnitOfWorkDo: 
    		[person	address: ((GlorpAddress new) id: 12; street: 'foo'; number: '1234')].
    	self readPerson.
    	self checkPerson.
    	self assert: person address class == Proxy.
    	self assert: person address getValue id = 12.
    	self assert: person address getValue street = 'foo'.].!

testReadPersonWithAddress
    self inTransactionDo: [
    	self writePersonWithAddress.
    	self readPerson.
    	self checkPerson.
    	self checkAddress].!

testReadPersonWithoutAddress
    self inTransactionDo: [
    	self writeHomelessPerson.
    	self writeAddress.
    	self readPerson.
    	self checkPerson.
    	self checkNoAddress].! !

!GlorpOneToOneDBTest methodsFor: 'support'!

checkAddress
    self assert: person address class == Proxy.
    self assert: person address getValue id = 123.
    ^self assert: person address getValue class == GlorpAddress.!

checkNoAddress
    self assert: person address class == Proxy.
    self assert: person address getValue == nil.!

checkNoAddressesInDB
    | addresses addressKeys |
    addresses := session accessor executeSQLString: 'SELECT * FROM GR_ADDRESS'.
    self assert: addresses isEmpty.
    addressKeys := session accessor executeSQLString: 'SELECT ADDRESS_ID FROM PERSON'.
    self assert: (addressKeys size = 1).
    self assert: (addressKeys first atIndex: 1) = nil.!

checkPerson
    self assert: person class = GlorpPerson.
    self assert: person id = personId.
    self assert: person name = 'aPerson'.!

inUnitOfWorkDo: aBlock
    "Set up a bunch of the normal data, read the objects, then run the block in a unit of work"
    self inUnitOfWorkDo: aBlock initializeWith: [self writePersonWithAddress].!

inUnitOfWorkDo: aBlock initializeWith: initBlock
    "Set up a bunch of the normal data, read the objects, then run the block in a unit of work"
    initBlock value.
    session beginUnitOfWork.
    self readPerson.
    aBlock value.
    session commitUnitOfWork.
    session reset.!

readPerson
    | results query |
    query := Query
    	returningManyOf: GlorpPerson
    	where: [:pers | pers id = personId].
    results := query executeIn: session.
    self assert: results size = 1.
    person := results first.!

writeAddress
    | addressRow |
    addressRow := session system exampleAddressRow.
    session writeRow: addressRow.!

writeHomefulPerson
    | personRow |
    personRow := session system examplePersonRow1.
    session writeRow: personRow.
    personId := personRow atFieldNamed: 'ID'.!

writeHomelessPerson
    | personRow |
    personRow := session system examplePersonRow2.
    session writeRow: personRow.
    personId := personRow atFieldNamed: 'ID'.!

writePersonWithAddress
    self writeAddress.
    self writeHomefulPerson.! !

!GlorpOneToOneDBTest methodsFor: 'tests-write'!

testWritePersonWithAddress
    |newPerson |
    self inTransactionDo: [
    	session beginUnitOfWork.
    	newPerson := GlorpPerson example1.
    	personId := newPerson id.
    	session register: newPerson.
    	session commitUnitOfWork.
    	session reset.
    	self readPerson.
    	self assert: person id = newPerson id.
    	self assert: person name = newPerson name.
    	self assert: person address id = newPerson address id.
    	self assert: person address street = newPerson address street].!

testWritePersonWithoutAddress
    |newPerson |
    self inTransactionDo: [
    	session beginUnitOfWork.
    	newPerson := GlorpPerson example1.
    	newPerson address: nil.
    	personId := newPerson id.
    	session register: newPerson.
    	session commitUnitOfWork.
    	session reset.
    	self readPerson.
    	self assert: person id = newPerson id.
    	self assert: person name = newPerson name.
    	self assert: person address yourself == nil.
    	self checkNoAddressesInDB].! !

!GlorpOneToOneDBTest methodsFor: 'tests-join'!

testReadPersonWithJoinToAddress
    | people |
    self inTransactionDo: [
    	self writePersonWithAddress.
    	people := session readManyOf: GlorpPerson where: [:eachPerson | eachPerson address street = 'Paseo Montril'].
    	self assert: people size = 1.
    	person := people first.
    	self assert: person address street = 'Paseo Montril'.
    	self assert: person address id = 123].! !

!GlorpOneToOneDBTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpReadingPersonWithEmailAddressesTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    session beginTransaction.
    addressRow := session system exampleAddressRow.
    session writeRow: addressRow.
    personRow := session system examplePersonRow1.
    session writeRow: personRow.
    emailAddress1Row := session system exampleEmailAddressRow1.
    emailAddress2Row := session system exampleEmailAddressRow2.
    id1 := emailAddress1Row at: (emailAddress1Row table fieldNamed: 'ID').
    id2 := emailAddress2Row at: (emailAddress2Row table fieldNamed: 'ID').
    session writeRow: emailAddress1Row.
    session writeRow: emailAddress2Row.!

tearDown
    super tearDown.
    session rollbackTransaction.
    session reset.
    session := nil.! !

!GlorpReadingPersonWithEmailAddressesTest methodsFor: 'tests'!

testObjectsNotAddedTwiceWhenReadingMultipleObjectsOneToMany
    "Read in the objects first, so they're in cache. Make sure they don't get the collection built up twice."
    | people |

    people := session readManyOf: GlorpPerson.
    self testReadMultipleObjectsOneToMany.
    ^people.!

testPreparedStatementsAreFaster
    "Not really a good test, since there are lots of other factors. And since we don't support this on all dialects/databases, they might easily be the same. Maybe should remove this test, but on the other hand it's the most useful feedback that the prepared statements are actually good for something"
    | timePrepared timeUnPrepared| 
    session reusePreparedStatements: true.
    session reset.
    timeUnPrepared := Time millisecondsToRun: [
    	session readManyOf: GlorpPerson where: [:eachPerson | eachPerson id = 3].
    	session readManyOf: GlorpPerson where: [:eachPerson | eachPerson id ~= 3].
    	session readManyOf: GlorpPerson where: [:eachPerson | eachPerson id >= 3]].
    session reset.
    timePrepared := Time millisecondsToRun: [
    	3 timesRepeat: [ | query |
    		query := Query returningManyOf: GlorpPerson where: [:eachPerson | eachPerson id = (eachPerson parameter: 1)].
    		query executeWithParameters: #(3) in: session]].
    (session accessor numberOfPreparedStatements >= 1) ifFalse: [^self  "Don't bother testing, not supported"].
    Transcript nl; show: 'Time reusing prepared statements = ', timePrepared printString.
    Transcript nl; show: 'Time not reusing prepared statements = ', timeUnPrepared printString.
    "Give a little bit of room, so if they take roughly the same amount of time it'll still pass"
    self assert: (timePrepared * 0.8 )< timeUnPrepared.!

testPreparedStatementsAreReused
    | | 
    "This test only makes sense if binding is on" 
    session useBinding ifFalse: [^self].
    session reusePreparedStatements: true.
    session reset.
    session readManyOf: GlorpPerson where: [:eachPerson | eachPerson id = 3].
    session readManyOf: GlorpPerson where: [:eachPerson | eachPerson id ~= 3].
    session readManyOf: GlorpPerson where: [:eachPerson | eachPerson id >= 3].
    self assert: session accessor numberOfPreparedStatements = 3.
    session reset.
    1 to: 3 do: [:i | | query |
    		query := Query returningManyOf: GlorpPerson where: [:eachPerson | eachPerson id = (eachPerson parameter: 1)].
    		query executeWithParameters: (Array with: i) in: session].
    self assert: session accessor numberOfPreparedStatements = 1.!

testReadMultipleObjectsOneToMany
    | query result person addresses |

    query := Query returningManyOf: GlorpPerson where: [:eachPerson | eachPerson id = 3].
    query alsoFetch: [:each | each emailAddresses].
    result := query executeIn: session.
    self assert: result size = 1.
    person := result first.
    addresses := person emailAddresses.
    self deny: addresses class == Proxy.
    self assert: addresses size = 2.
    self 
    	assert: (addresses first id = id1 or: [addresses last id = id1]).
    self 
    	assert: (addresses first id = id2 or: [addresses last id = id2]).
    self assert: addresses first id ~= addresses last id.!

testReadPersonWithEmailAddresses
    | query result emailAddresses |
    query := Query
    	returningOneOf:GlorpPerson
    	where: [:person | person id = 3].
    result := query executeIn: session.
    emailAddresses := result emailAddresses getValue.
    self assert: emailAddresses size = 2.
    self
    	assert:
    		(emailAddresses first id = id1 or: [emailAddresses last id = id1]).
    self
    	assert:
    		(emailAddresses first id = id2 or: [emailAddresses last id = id2]).
    self assert: emailAddresses first id ~= emailAddresses last id.! !

!GlorpReadingPersonWithEmailAddressesTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpReadingPersonWithEmailAddressesTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpReadQueryTest methodsFor: 'tests-ordering'!

helpTestSingleOrderingBy: aBlock setup: setupBlock
    | query result realBlock |
    query := Query returningManyOf: GlorpAddress.
    query orderBy: aBlock.
    realBlock := query expressionBlockFor: aBlock.
    result := session execute: query.
    self verifyOrderFor: result byAttribute: realBlock.!

testDescendingSingleOrdering
    | query result sortedResult |
    
    query := Query returningManyOf: GlorpAddress where: [:each | each street ~= 'Beta'].
    query orderBy: [:each | each street descending].
    result := session execute: query.
    sortedResult := result 
    			asSortedCollection: [:a :b | a street > b street].
    self assert: sortedResult asArray = result asArray.!

testDoubleOrderingAddress
    | query |
    query := Query returningManyOf: GlorpAddress.
    query orderBy: [:each | each street].
    query orderBy: [:each | each number].
    self validateDoubleOrderFor: query.!

testMixedDoubleOrderingAddress
    | query |
    query := Query returningManyOf: GlorpAddress.
    query orderBy: [:each | each street descending].
    query orderBy: [:each | each number].
    self validateDoubleOrderMixedFor: query.!

testOrderingByRelatedObjectAttribute
    | query result |
    query := Query returningManyOf: GlorpPerson.
    query orderBy: [:each | each address street].
    result := session execute: query.
    self verifyOrderFor: result byAttribute: [:each | each address street].!

testOrderingWithNonEmptyWhereClause
    | query result |
    query := Query returningManyOf: GlorpPerson where: [:each | each id ~= 12].
    query orderBy: #(#address #street).
    result := session execute: query.
    self verifyOrderFor: result byAttribute: [:each | each address street].!

testSingleOrderingAddress1
    self 
    	helpTestSingleOrderingBy: [:each | each street]
    	setup: [self writeAddressOrderingRows].!

testSingleOrderingAddress2
    self 
    	helpTestSingleOrderingBy: [:each | each number]
    	setup: [self writeAddressOrderingRows].!

testSingleOrderingBySymbol
    self 
    	helpTestSingleOrderingBy: #street
    	setup: [self writeAddressOrderingRows].!

testSymbolsOrderingByRelatedObjectAttribute
    | query result |
    query := Query returningManyOf: GlorpPerson.
    query orderBy: #(#address #street).
    result := session execute: query.
    self verifyOrderFor: result byAttribute: [:each | each address street].! !

!GlorpReadQueryTest methodsFor: 'tests-data reading'!

testReadDataItemsFromEmbeddedObject
    | query result transRow id |
    transRow := session system exampleBankTransactionRow.
    session writeRow: transRow.
    id := transRow atFieldNamed: 'ID'.
    query := Query returningManyOf: GlorpBankTransaction.
    query retrieve: [:each | each id].
    query retrieve: [:each | each serviceCharge description].
    result := query executeIn: session.
    self assert: result size = 1.
    self assert: result first = (Array with: id with: 'additional overcharge').!

testReadDistinctIds
    | query result |
    query := Query returningManyOf: GlorpPerson.
    query retrieve: [:each | each id distinct].
    result := query executeIn: session.
    self assert: (result asSortedCollection asArray = #(86 87 88)).!

testReadDistinctIdsWithWhereClause
    | query result |
    query := Query returningManyOf: GlorpPerson.
    query retrieve: [:each | each id distinct].
    query criteria: [:each | each id ~= 423421].
    result := query executeIn: session.
    self assert: (result asSortedCollection asArray = #(86 87 88)).!

testReadDistinctRelatedAttribute
    | query result allStreets |
    query := Query returningManyOf: GlorpPerson.
    query retrieve: [:each | each address street distinct].
    result := query executeIn: session.
    self assert: (result asSortedCollection asArray = #('Alpha' 'Beta' 'Gamma')).
    allStreets := (session readManyOf: GlorpAddress) collect: [:each | each street].
    self assert: allStreets size = 5.!

testReadObjectsAndData
    | query result tracing addressReadSeparately personReadSeparately |
    query := Query returningManyOf: GlorpPerson.
    tracing := Tracing new.
    tracing retrieve: [:each | each id].
    tracing retrieve: [:each | each address].
    query tracing: tracing.
    query orderBy: #id.
    result := query executeIn: session.
    self assert: result size = 3.
    self assert: (result first at: 1) = 86.
    self assert: ((result first at: 2) class == GlorpAddress).
    self assert: ((result first at: 2) id = 2).
    addressReadSeparately := session readOneOf: GlorpAddress where: [:each | each id = 2].
    self assert: result first last == addressReadSeparately.
    personReadSeparately := session readOneOf: GlorpPerson where: [:each | each id = 86].
    self assert: personReadSeparately address yourself == result first last.!

testReadOneWithObjects
    | query result |
    query := Query returningOneOf: GlorpPerson where: [:each | each id = 86].
    query retrieve: [:each | each].
    query retrieve: [:each | each address].
    query orderBy: [:each | each id].
    result := query executeIn: session.
    self assert: result first id = 86.
    self assert: (result first address yourself == result last).!

testReadOnlyPrimaryKeys
    | query result |
    query := Query returningManyOf: GlorpPerson.
    query retrieve: [:each | each id].
    result := query executeIn: session.
    self assert: (result asSortedCollection asArray = #(86 87 88)).!

testReadTwoDataItems
    | query result tracing|
    query := Query returningManyOf: GlorpPerson.
    tracing := Tracing new.
    tracing retrieve: [:each | each id].
    tracing retrieve: [:each | each name].
    query tracing: tracing.
    result := query executeIn: session.
    self assert: result size = 3.
    self assert: result first = #(86 'person1').
    self assert: (result at: 2) = #(87 'person2').
    self assert: result last = #(88 'person3').!

testReadTwoDataItemsFromDifferentObjects
    | query result tracing|
    query := Query returningManyOf: GlorpPerson.
    tracing := Tracing new.
    tracing retrieve: [:each | each id].
    tracing retrieve: [:each | each address street].
    query tracing: tracing.
    query orderBy: #id.
    result := query executeIn: session.
    self assert: result size = 3.
    self assert: result first = #(86 'Beta').
    self assert: (result at: 2) = #(87 'Gamma').
    self assert: result last = #(88 'Alpha').!

testReadTwoObjects
    | query result |
    query := Query returningManyOf: GlorpPerson.
    query retrieve: [:each | each].
    query retrieve: [:each | each address].
    query orderBy: [:each | each id].
    result := query executeIn: session.
    self assert: result size = 3.
    self assert: (result first atIndex: 1) id = 86.
    self assert: ((result first atIndex: 1) address yourself == result first last).! !

!GlorpReadQueryTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    session system: (GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database).
    session beginTransaction.
    self writeAddressDoubleOrderingRows.
    self writePersonOrderingRows.!

tearDown
    super tearDown.
    session rollbackTransaction.
    session reset.
    session := nil.!

validateDoubleOrderFor: query 
    | result sortedResult |
    result := session execute: query.
    sortedResult := result asSortedCollection: 
    				[:a :b | 
    				a street = b street 
    					ifTrue: [a number <= b number]
    					ifFalse: [a street < b street]].
    ^self assert: sortedResult asArray = result asArray!

validateDoubleOrderMixedFor: query 
    | result sortedResult |
    result := session execute: query.
    sortedResult := result asSortedCollection: 
    				[:a :b | 
    				a street = b street 
    					ifTrue: [a number <= b number]
    					ifFalse: [a street > b street]].
    ^self assert: sortedResult asArray = result asArray!

verifyOrderFor: result byAttribute: aBlock
    1 to: result size - 1
    	do: 
    		[:i | 
    		| a b |
    		a := result at: i.
    		b := result at: i + 1.
    		self assert: (aBlock value: a) <= (aBlock value: b)]!

writeAddressDoubleOrderingRows
    self writeAddressOrderingRows.
    session writeRow: session system exampleAddressRowForOrdering4.
    session writeRow: session system exampleAddressRowForOrdering5.!

writeAddressOrderingRows
    session writeRow: session system exampleAddressRowForOrdering1.
    session writeRow: session system exampleAddressRowForOrdering2.
    session writeRow: session system exampleAddressRowForOrdering3.!

writePersonOrderingRows
    session writeRow: session system examplePersonRowForOrdering1.
    session writeRow: session system examplePersonRowForOrdering2.
    session writeRow: session system examplePersonRowForOrdering3.! !

!GlorpReadQueryTest methodsFor: 'tests'!

testCriteriaSetup
    | query |
    query := Query returningOneOf: GlorpAddress where: [:each | each id = 12].
    query session: session.
    query setUpCriteria.
    self assert: query criteria class == RelationExpression.
    self assert: query criteria ultimateBaseExpression descriptor 
    			== (session descriptorFor: GlorpAddress)!

testIn
    | query result |
    
    query := Query returningManyOf: GlorpAddress where: [:each | each street in: #('Beta' 'Alpha')].
    result := session execute: query.
    self assert: (result allSatisfy: [:each | #('Beta' 'Alpha') includes: each street]).
    self assert: result size = 4.!

testInInteger
    | query result |
    
    query := Query returningManyOf: GlorpAddress where: [:each | each id in: #(1 2)].
    result := session execute: query.
    self assert: (result allSatisfy: [:each | #(1 2) includes: each id]).
    self assert: result size = 2.!

testInSymbol
    | query result transRow transRow2 |
    transRow := session system exampleBankTransactionRow.
    session writeRow: transRow.	
    transRow2 := session system exampleBankTransactionRow2.
    session writeRow: transRow2.	
    query := Query returningManyOf: GlorpBankTransaction where: [:each | each amount currency in: #(#USD #CDN)].
    result := session execute: query.
    self assert: (result allSatisfy: [:each | each amount currency = #CDN]).
    self assert: result size = 1.
    query := Query returningManyOf: GlorpBankTransaction where: [:each | each amount currency in: #(#USD #DM)].
    result := session execute: query.
    self assert: result isEmpty.!

testLike
    | query result |
    
    query := Query returningManyOf: GlorpAddress where: [:each | each street like: 'Be%'].
    result := session execute: query.
    self assert: (result allSatisfy: [:each | each street = 'Beta']).
    self assert: result size = 3.!

testReadMultipleObjects
    | query result tracing addressReadSeparately personReadSeparately allResults |
    query := Query returningManyOf: GlorpPerson.
    tracing := Tracing new.
    tracing retrieve: [:each | each ].
    tracing retrieve: [:each | each address].
    query tracing: tracing.
    query orderBy: #id.
    allResults := query executeIn: session.
    self assert: allResults size = 3.
    result := allResults first.
    self assert: (result at: 1) id = 86.
    self assert: ((result at: 1) class == GlorpPerson).
    self assert: (result at: 1) address == (result at: 2).
    self assert: ((result at: 2) class == GlorpAddress).
    self assert: ((result at: 2) id = 2).
    addressReadSeparately := session readOneOf: GlorpAddress where: [:each | each id = 2].
    self assert: result last == addressReadSeparately.
    personReadSeparately := session readOneOf: GlorpPerson where: [:each | each id = 86].
    self assert: personReadSeparately == result first.
    self assert: personReadSeparately address yourself == result last.! !

!GlorpReadQueryTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpReadQueryTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTestDescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDemoDescriptorSystem methodsFor: 'tables'!

tableForBANK_ACCT: aTable
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'BANK_CODE' type: (platform varChar: 10).
    aTable createFieldNamed: 'BRANCH_NO' type: (platform int4).
    aTable createFieldNamed: 'ACCT_NO' type: (platform varChar: 10).!

tableForBANK_TRANS: aTable 
    | ownerId |
    (aTable createFieldNamed: 'ID' type: platform serial)
    	bePrimaryKey.
    ownerId := aTable createFieldNamed: 'OWNER_ID' type: platform int4.
    aTable addForeignKeyFrom: ownerId
    	to: ((self tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID').
    aTable createFieldNamed: 'AMT_CURR' type: (platform varChar: 5).
    aTable createFieldNamed: 'AMT_AMT' type: platform int4.
    aTable createFieldNamed: 'SRVC_DESC' type: (platform varChar: 30).
    aTable createFieldNamed: 'SRVC_AMT_CURR' type: (platform varChar: 5).
    aTable createFieldNamed: 'SRVC_AMT_AMT' type: platform int4.!

tableForCOMPRESSED_MONEY_TABLE: aTable
    (aTable createFieldNamed: 'ID' type: platform int4)
    	bePrimaryKey.
    aTable createFieldNamed: 'CURRENCY_NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'AMOUNT' type: platform int4.!

tableForCUSTOMER_ACCT_LINK: aTable
    | customerId accountId |
    customerId := (aTable createFieldNamed: 'CUSTOMER_ID' type: platform int4).
    aTable addForeignKeyFrom: customerId to: ((self tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID').
    accountId := aTable createFieldNamed: 'ACCT_ID' type: platform int4.
    aTable addForeignKeyFrom: accountId to: ((self tableNamed: 'BANK_ACCT') fieldNamed: 'ID').!

tableForEMAIL_ADDRESS: aTable
    | personId |
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'USER_NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'HOST_NAME' type: (platform varChar: 20).
    personId := aTable createFieldNamed: 'PERSON_ID' type: platform int4.
    aTable addForeignKeyFrom: personId to: ((self tableNamed: 'PERSON') fieldNamed: 'ID').!

tableForFKADDRESS: aTable 
    | contact |
    (aTable createFieldNamed: 'ID' type: platform serial) bePrimaryKey.
    contact := aTable createFieldNamed: 'CONTACT_ID' type: platform int4.
    aTable addForeignKeyFrom: contact
    	to: ((self tableNamed: 'FKCONTACT') fieldNamed: 'ID')!

tableForFKCONTACT: aTable 
    | address |
    (aTable createFieldNamed: 'ID' type: platform serial) bePrimaryKey.
    address := aTable createFieldNamed: 'ADDRESS_ID' type: platform int4.
    aTable addForeignKeyFrom: address
    	to: ((self tableNamed: 'FKADDRESS') fieldNamed: 'ID')!

tableForGR_ADDRESS: aTable 
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'STREET' type: (platform varChar: 20).
    aTable createFieldNamed: 'HOUSE_NUM' type: (platform varChar: 20)!

tableForGR_CUSTOMER: aTable 
    (aTable createFieldNamed: 'ID' type: platform int4)
    	bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20)!

tableForMONEY_IMAGINARY_TABLE: aTable
    aTable createFieldNamed: 'CURRENCY' type: (platform varChar: 5).
    aTable createFieldNamed: 'AMOUNT' type: platform int4!

tableForPERSON: aTable
    | addrId|
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    addrId := aTable createFieldNamed: 'ADDRESS_ID' type: platform int4.
    aTable addForeignKeyFrom: addrId to: ((self tableNamed: 'GR_ADDRESS') fieldNamed: 'ID').!

tableForRESERVATION: aTable 
    (aTable createFieldNamed: 'ID' type: platform int4)
    	bePrimaryKey.
    aTable createFieldNamed: 'PASS_ID' type: (platform int4)!

tableForSTUFF: aTable 
    (aTable createFieldNamed: 'ID' type: platform inMemorySequence)
    	bePrimaryKey.
    aTable createFieldNamed: 'THING' type: (platform varChar: 20)!

tableForTRANSFORMED_TIME: aTable
    (aTable createFieldNamed: 'ID' type: platform int4)
    	bePrimaryKey.
    aTable createFieldNamed: 'TIMEFIELD' type: platform int4.! !

!GlorpDemoDescriptorSystem methodsFor: 'examples'!

exampleAccountRow1
    | accountTable row |
    accountTable := self tableNamed: 'BANK_ACCT'.
    row := DatabaseRow newForTable: accountTable.
    row at: (accountTable fieldNamed: 'ID') put: 9874.
    row at: (accountTable fieldNamed: 'BANK_CODE') put: 1.
    row at: (accountTable fieldNamed: 'BRANCH_NO') put: 2.
    row at: (accountTable fieldNamed: 'ACCT_NO') put: 3.
    ^row.!

exampleAccountRow2
    | accountTable row |
    accountTable := self tableNamed: 'BANK_ACCT'.
    row := DatabaseRow newForTable: accountTable.
    row at: (accountTable fieldNamed: 'ID') put: 6.
    row at: (accountTable fieldNamed: 'BANK_CODE') put: 2.
    row at: (accountTable fieldNamed: 'BRANCH_NO') put: 3.
    row at: (accountTable fieldNamed: 'ACCT_NO') put: 4.
    ^row.!

exampleAccountRow3
    | accountTable row |
    accountTable := self tableNamed: 'BANK_ACCT'.
    row := DatabaseRow newForTable: accountTable.
    row at: (accountTable fieldNamed: 'ID') put: 22.
    row at: (accountTable fieldNamed: 'BANK_CODE') put: 2.
    row at: (accountTable fieldNamed: 'BRANCH_NO') put: 712.
    row at: (accountTable fieldNamed: 'ACCT_NO') put: 5551212.
    ^row.!

exampleAddressRow
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 123.
    row at: (addressTable fieldNamed: 'STREET') put: 'Paseo Montril'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '10185'.
    ^row!

exampleAddressRowForOrdering1
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 1.
    row at: (addressTable fieldNamed: 'STREET') put: 'Alpha'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '300'.
    ^row!

exampleAddressRowForOrdering2
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 2.
    row at: (addressTable fieldNamed: 'STREET') put: 'Beta'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '200'.
    ^row!

exampleAddressRowForOrdering3
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 3.
    row at: (addressTable fieldNamed: 'STREET') put: 'Gamma'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '100'.
    ^row!

exampleAddressRowForOrdering4
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 6.
    row at: (addressTable fieldNamed: 'STREET') put: 'Beta'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '120'.
    ^row!

exampleAddressRowForOrdering5
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 4.
    row at: (addressTable fieldNamed: 'STREET') put: 'Beta'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '130'.
    ^row!

exampleAddressRowWithDifferentStreet
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 123.
    row at: (addressTable fieldNamed: 'STREET') put: 'Garden of the Gods'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '10185'.
    ^row!

exampleBankTransactionRow
    | table row |
    table := self tableNamed: 'BANK_TRANS'.
    row := DatabaseRow newForTable: table.

    row atFieldNamed: 'ID' put: nil.
    row atFieldNamed: 'OWNER_ID' put: nil.
    row atFieldNamed: 'AMT_CURR' put: 'CDN'.
    row atFieldNamed: 'AMT_AMT' put: 7.
    row atFieldNamed: 'SRVC_DESC' put: 'additional overcharge'.
    row atFieldNamed: 'SRVC_AMT_CURR' put: 'USD'.
    row atFieldNamed: 'SRVC_AMT_AMT' put: 2.

    ^row!

exampleBankTransactionRow2
    | table row |
    table := self tableNamed: 'BANK_TRANS'.
    row := DatabaseRow newForTable: table.

    row atFieldNamed: 'ID' put: nil.
    row atFieldNamed: 'OWNER_ID' put: nil.
    row atFieldNamed: 'AMT_CURR' put: 'EUR'.
    row atFieldNamed: 'AMT_AMT' put: 45.
    row atFieldNamed: 'SRVC_DESC' put: 'deposit'.
    row atFieldNamed: 'SRVC_AMT_CURR' put: 'EUR'.
    row atFieldNamed: 'SRVC_AMT_AMT' put: 1.

    ^row!

exampleCALinkRow1
    | linkTable row |
    linkTable := self tableNamed: 'CUSTOMER_ACCT_LINK'.
    row := DatabaseRow newForTable: linkTable.
    row at: (linkTable fieldNamed: 'ACCT_ID') put: 9874.
    row at: (linkTable fieldNamed: 'CUSTOMER_ID') put: 27.
    ^row.!

exampleCALinkRow2
    | linkTable row |
    linkTable := self tableNamed: 'CUSTOMER_ACCT_LINK'.
    row := DatabaseRow newForTable: linkTable.
    row at: (linkTable fieldNamed: 'ACCT_ID') put: 6.
    row at: (linkTable fieldNamed: 'CUSTOMER_ID') put: 27.
    ^row.!

exampleCALinkRow3
    | linkTable row |
    linkTable := self tableNamed: 'CUSTOMER_ACCT_LINK'.
    row := DatabaseRow newForTable: linkTable.
    row at: (linkTable fieldNamed: 'ACCT_ID') put: 22.
    row at: (linkTable fieldNamed: 'CUSTOMER_ID') put: 28.
    ^row.!

exampleCompressedMoneyRow
    | table row |
    table := self  tableNamed: 'COMPRESSED_MONEY_TABLE'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'ID') put: 123.
    row at: (table fieldNamed: 'AMOUNT') put: 12.
    row at: (table fieldNamed: 'CURRENCY_NAME') put: 'CDN'.
    ^row!

exampleCompressedMoneyRow2
    | table row |
    table := self  tableNamed: 'COMPRESSED_MONEY_TABLE'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'ID') put: 124.
    row at: (table fieldNamed: 'AMOUNT') put: 15.
    row at: (table fieldNamed: 'CURRENCY_NAME') put: 'CDN'.
    ^row!

exampleCustomerRow1
    | customerTable row |
    customerTable := self tableNamed: 'GR_CUSTOMER'.
    row := DatabaseRow newForTable: customerTable.
    row at: (customerTable fieldNamed: 'ID') put: 27.
    row at: (customerTable fieldNamed: 'NAME') put: 'aCustomer'.
    ^row.!

exampleCustomerRow2
    | customerTable row |
    customerTable := self tableNamed: 'GR_CUSTOMER'.
    row := DatabaseRow newForTable: customerTable.
    row at: (customerTable fieldNamed: 'ID') put: 28.
    row at: (customerTable fieldNamed: 'NAME') put: 'anotherCustomer'.
    ^row.!

exampleEmailAddressRow1
    | personTable row |
    personTable := self tableNamed: 'EMAIL_ADDRESS'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 42.
    row at: (personTable fieldNamed: 'USER_NAME') put: 'alan'.
    row at: (personTable fieldNamed: 'HOST_NAME') put: 'objectpeople.com'.
    row at: (personTable fieldNamed: 'PERSON_ID') put: 3.

    ^row.!

exampleEmailAddressRow2
    | personTable row |
    personTable := self tableNamed: 'EMAIL_ADDRESS'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 54321.
    row at: (personTable fieldNamed: 'USER_NAME') put: 'johnson'.
    row at: (personTable fieldNamed: 'HOST_NAME') put: 'cs.uiuc.edu'.
    row at: (personTable fieldNamed: 'PERSON_ID') put: 3.
    ^row.!

exampleFrequentFlyerRow
    | ffTable row |
    ffTable := self tableNamed: 'FREQUENT_FLYER'.
    row := DatabaseRow newForTable: ffTable.
    row at: (ffTable fieldNamed: 'ID') put: 1.
    row at: (ffTable fieldNamed: 'POINTS') put: 10000.
    row at: (ffTable fieldNamed: 'AIRLINE_ID') put: nil.
    ^row.!

exampleModifiedAddressRow
    | addressTable row |
    addressTable := self  tableNamed: 'GR_ADDRESS'.
    row := DatabaseRow newForTable: addressTable.
    row at: (addressTable fieldNamed: 'ID') put: 123.
    row at: (addressTable fieldNamed: 'STREET') put: 'Something Else'.
    row at: (addressTable fieldNamed: 'HOUSE_NUM') put: '10185'.
    ^row!

examplePassengerRow
    | passengerTable row |
    passengerTable := self tableNamed: 'PASSENGER'.
    row := DatabaseRow newForTable: passengerTable.
    row at: (passengerTable fieldNamed: 'ID') put: 1.
    row at: (passengerTable fieldNamed: 'NAME') put: 'Some Passenger'.
    ^row.!

examplePersonRow1
    | personTable row |
    personTable := self tableNamed: 'PERSON'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 3.
    row at: (personTable fieldNamed: 'NAME') put: 'aPerson'.
    row at: (personTable fieldNamed: 'ADDRESS_ID') put: 123.
    ^row.!

examplePersonRow2
    | personTable row |
    personTable := self tableNamed: 'PERSON'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 4.
    row at: (personTable fieldNamed: 'NAME') put: 'aPerson'.
    row at: (personTable fieldNamed: 'ADDRESS_ID') put: nil.
    ^row.!

examplePersonRowForOrdering1
    | personTable row |
    personTable := self tableNamed: 'PERSON'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 86.
    row at: (personTable fieldNamed: 'NAME') put: 'person1'.
    row at: (personTable fieldNamed: 'ADDRESS_ID') put: 2.
    ^row.!

examplePersonRowForOrdering2
    | personTable row |
    personTable := self tableNamed: 'PERSON'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 87.
    row at: (personTable fieldNamed: 'NAME') put: 'person2'.
    row at: (personTable fieldNamed: 'ADDRESS_ID') put: 3.
    ^row.!

examplePersonRowForOrdering3
    | personTable row |
    personTable := self tableNamed: 'PERSON'.
    row := DatabaseRow newForTable: personTable.
    row at: (personTable fieldNamed: 'ID') put: 88.
    row at: (personTable fieldNamed: 'NAME') put: 'person3'.
    row at: (personTable fieldNamed: 'ADDRESS_ID') put: 1.
    ^row.! !

!GlorpDemoDescriptorSystem methodsFor: 'descriptors/airline'!

descriptorForGlorpAirline: aDescriptor 
    | table |
    table := self tableNamed: 'AIRLINE'.
    aDescriptor table: (self tableNamed: 'AIRLINE').
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    ^aDescriptor!

descriptorForGlorpItinerary: aDescriptor 
    | table |
    table := self tableNamed: 'ITINERARY'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (
    	OneToOneMapping new
    		attributeName: #reservation;
    		referenceClass: GlorpReservation;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'RES_ID')
    			to: ((self tableNamed: 'RESERVATION') fieldNamed: 'ID'))).
    ^aDescriptor!

descriptorForGlorpPassenger: aDescriptor 
    | passTable ffTable |
    passTable := self tableNamed: 'PASSENGER'.
    ffTable := self tableNamed: 'FREQUENT_FLYER'.
    aDescriptor table: passTable.
    aDescriptor addTable: ffTable.
    aDescriptor addMultipleTableCriteria: (	
    	Join 
    		from: (passTable fieldNamed: 'ID')
    		to: (ffTable fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #id to: (passTable fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (passTable fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #frequentFlyerMiles to: (ffTable fieldNamed: 'POINTS')).
    aDescriptor addMapping: (	
    	OneToOneMapping new
    		attributeName: #airline;
    		referenceClass: GlorpAirline;
    		mappingCriteria: (Join 
    			from: (ffTable fieldNamed: 'AIRLINE_ID')
    			to: ((self tableNamed: 'AIRLINE') fieldNamed: 'ID'))).


    ^aDescriptor!

descriptorForGlorpReservation: aDescriptor 
    | table |
    table := self tableNamed: 'RESERVATION'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    "The res->passenger relationship is actually 1-1, but map it as both 1-1 and 1-many so that we can more easily verify that only one object comes back, i.e. that joins are being done correctly"
    aDescriptor addMapping: (	
    	OneToManyMapping new
    		attributeName: #passengers;
    		referenceClass: GlorpPassenger;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'PASS_ID')
    			to: ((self tableNamed: 'PASSENGER') fieldNamed: 'ID'))).
    aDescriptor addMapping: (	
    	OneToOneMapping new
    		attributeName: #passenger;
    		referenceClass: GlorpPassenger;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'PASS_ID')
    			to: ((self tableNamed: 'PASSENGER') fieldNamed: 'ID'))).
    ^aDescriptor! !

!GlorpDemoDescriptorSystem methodsFor: 'descriptors/bank'!

descriptorForGlorpBankAccount: aDescriptor 
    | table |
    table := self tableNamed: 'BANK_ACCT'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id
    			to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: ((ManyToManyMapping new)
    			attributeName: #accountHolders;
    			referenceClass: GlorpCustomer;
    			mappingCriteria: (Join 
    						from: (table fieldNamed: 'ID')
    						to: ((self tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'ACCT_ID'))).
    aDescriptor addMapping: ((EmbeddedValueOneToOneMapping new)
    			attributeName: #accountNumber;
    			referenceClass: GlorpBankAccountNumber).
    ^aDescriptor!

descriptorForGlorpBankAccountNumber: aDescriptor
    | table |
    table := self tableNamed: 'BANK_ACCT'.
    aDescriptor table: table.
    aDescriptor addMapping: (	
    	DirectMapping from: #bankCode to: (table fieldNamed: 'BANK_CODE')).
    aDescriptor addMapping: (	
    	DirectMapping from: #branchNumber to: (table fieldNamed: 'BRANCH_NO')).
    aDescriptor addMapping: (	
    	DirectMapping from: #accountNumber to: (table fieldNamed: 'ACCT_NO')).
    ^aDescriptor.!

descriptorForGlorpBankTransaction: aDescriptor
    | table | 
    table := self tableNamed: 'BANK_TRANS'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id
    			to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: ((OneToOneMapping new)
    			attributeName: #owner;
    			referenceClass: GlorpCustomer;
    			mappingCriteria: (Join 
    						from: (table fieldNamed: 'OWNER_ID')
    						to: ((self tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID'))).
    aDescriptor addMapping: ((EmbeddedValueOneToOneMapping new)
    			attributeName: #amount;
    			referenceClass: GlorpMoney;
    			fieldTranslation: ((Join new)
    						addSource: (table fieldNamed: 'AMT_AMT')
    							target: ((self tableNamed: 'MONEY_IMAGINARY_TABLE') fieldNamed: 'AMOUNT');
    						addSource: (table fieldNamed: 'AMT_CURR')
    							target: ((self tableNamed: 'MONEY_IMAGINARY_TABLE') fieldNamed: 'CURRENCY');
    						yourself)).
    aDescriptor addMapping: ((EmbeddedValueOneToOneMapping new)
    			attributeName: #serviceCharge;
    			referenceClass: GlorpServiceCharge).
    ^aDescriptor!

descriptorForGlorpCustomer: aDescriptor
    | table |
    table := self tableNamed: 'GR_CUSTOMER'.
    aDescriptor table: table.
    aDescriptor addMapping: (	
    	DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (	
    	DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (	
    	OneToManyMapping new
    		attributeName: #transactions;
    		referenceClass: GlorpBankTransaction;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: ((self tableNamed: 'BANK_TRANS') fieldNamed: 'OWNER_ID'))).
    aDescriptor addMapping: (	
    	ManyToManyMapping new
    		attributeName: #accounts;
    		referenceClass: GlorpBankAccount;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: ((self tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'CUSTOMER_ID'))).

    "Two additional relationships, there to test ordering within a mapping, where the order is determined by a field in the link table"
    aDescriptor addMapping: (	
    	ManyToManyMapping new
    		attributeName: #accountsSortedById;
    		readOnly: true;
    		referenceClass: GlorpBankAccount;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: ((self tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'CUSTOMER_ID'));
    		orderBy: [:each | (each getTable: 'CUSTOMER_ACCT_LINK') getField: 'ACCT_ID']).
    aDescriptor addMapping: (	
    	ManyToManyMapping new
    		attributeName: #accountsSortedByIdDescending;
    		readOnly: true;
    		referenceClass: GlorpBankAccount;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: ((self tableNamed: 'CUSTOMER_ACCT_LINK') fieldNamed: 'CUSTOMER_ID'));
    		orderBy: [:each | ((each getTable: 'CUSTOMER_ACCT_LINK') getField: 'ACCT_ID') descending]).


    ^aDescriptor.!

descriptorForGlorpEmailAddress: aDescriptor
    | table |
    table := self tableNamed: 'EMAIL_ADDRESS'.
    aDescriptor table: table.
    aDescriptor addMapping: (	
    	DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (	
    	DirectMapping from: #user to: (table fieldNamed: 'USER_NAME')).
    aDescriptor addMapping: (	
    	DirectMapping from: #host to: (table fieldNamed: 'HOST_NAME')).
    ^aDescriptor.!

descriptorForGlorpMoney: aDescriptor
    | table |
    table := self tableNamed: 'MONEY_IMAGINARY_TABLE'.
    aDescriptor table: table.
    aDescriptor addMapping: (	
    	DirectMapping from: #currency type: Symbol to: (table fieldNamed: 'CURRENCY')).
    aDescriptor addMapping: (	
    	DirectMapping from: #amount to: (table fieldNamed: 'AMOUNT')).
    ^aDescriptor.!

descriptorForGlorpPerson: aDescriptor
    | table |
    table := self tableNamed: 'PERSON'.
    aDescriptor table: table.
    aDescriptor addMapping: (	
    	DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (	
    	DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (	 
    	OneToOneMapping new
    		attributeName: #address;
    		referenceClass: GlorpAddress;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ADDRESS_ID')
    			to: ((self tableNamed: 'GR_ADDRESS') fieldNamed: 'ID'))).
    aDescriptor addMapping: (
    	OneToManyMapping new
    		attributeName: #emailAddresses;
    		referenceClass: GlorpEmailAddress;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: ((self tableNamed: 'EMAIL_ADDRESS') fieldNamed: 'PERSON_ID'))).
    ^aDescriptor.!

descriptorForGlorpServiceCharge: aDescriptor 
    
    | table |
    table := self tableNamed: 'BANK_TRANS'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #description
    			to: (table fieldNamed: 'SRVC_DESC')).
    aDescriptor addMapping: ((EmbeddedValueOneToOneMapping new)
    			attributeName: #amount;
    			referenceClass: GlorpMoney;
    			fieldTranslation: ((Join new)
    						addSource: (table fieldNamed: 'SRVC_AMT_AMT')
    							target: ((self tableNamed: 'MONEY_IMAGINARY_TABLE') fieldNamed: 'AMOUNT');
    						addSource: (table fieldNamed: 'SRVC_AMT_CURR')
    							target: ((self tableNamed: 'MONEY_IMAGINARY_TABLE') fieldNamed: 'CURRENCY');
    						yourself)).
    ^aDescriptor! !

!GlorpDemoDescriptorSystem methodsFor: 'descriptors/other'!

descriptorForGlorpCompressedMoney: aDescriptor 
    | table currencyField amountField |
    table := self tableNamed: 'COMPRESSED_MONEY_TABLE'.
    aDescriptor 
    	addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    currencyField := table fieldNamed: 'CURRENCY_NAME'.
    amountField := table fieldNamed: 'AMOUNT'.
    aDescriptor table: table.
    aDescriptor addMapping: (AdHocMapping 
    			forAttribute: #array
    			fromDb: 
    				[:row :elementBuilder :context| 
    				Array with: (elementBuilder valueOfField: (context translateField: currencyField) in: row)
    					with: (elementBuilder valueOfField: (context translateField: amountField) in: row)]
    			toDb: 
    				[:rows :attribute | 
    				(rows at: table) at: currencyField put: (attribute at: 1).
    				(rows at: table) at: amountField put: (attribute at: 2)]
    			mappingFields: (Array with: currencyField with: amountField)).
    "Note that position won't work if we have a join. We need to take the elementbuilder into account"
    ^aDescriptor!

descriptorForGlorpTransformedTime: aDescriptor 
    | table timeField |
    table := self tableNamed: 'TRANSFORMED_TIME'.
    aDescriptor 
    	addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    timeField := table fieldNamed: 'TIMEFIELD'.
    aDescriptor table: table.
    aDescriptor addMapping: (AdHocMapping 
    			forAttribute: #time
    			fromDb: 
    				[:row :elementBuilder :context| 
    				Time fromSeconds: (elementBuilder valueOfField: (context translateField: timeField) in: row) ]
    			toDb: 
    				[:rows :attribute | 
    				(rows at: table) at: timeField put: attribute asSeconds]
    			mappingFields: (Array with: timeField)).
    "Note that position won't work if we have a join. We need to take the elementbuilder into account"
    ^aDescriptor! !

!GlorpDemoDescriptorSystem methodsFor: 'tables/airline'!

tableForAIRLINE: aTable
    (aTable createFieldNamed: 'ID' type: platform inMemorySequence) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20)!

tableForAIRLINE_MEAL: aTable
    aTable createFieldNamed: 'ID' type: platform int4.
    aTable createFieldNamed: 'DESCR' type: (platform varChar: 20).
    aTable createFieldNamed: 'FLIGHT_ID' type: platform int4!

tableForFLIGHT: aTable
    aTable name: 'FLIGHT'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'FLIGHT_NUM' type: platform int4!

tableForFLIGHT_PASS: aTable
    aTable name: 'FLIGHT_PASS'.
    aTable createFieldNamed: 'FLIGHT_ID' type: platform int4.
    aTable createFieldNamed: 'PASS_ID' type: platform int4.
    aTable createFieldNamed: 'AIRLINE_ID' type: platform int4.!

tableForFREQUENT_FLYER: aTable 
    | airlineId |
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'POINTS' type: platform int4.
    airlineId := aTable createFieldNamed: 'AIRLINE_ID' type: platform int4.
    aTable addForeignKeyFrom: airlineId to: ((self tableNamed: 'AIRLINE') fieldNamed: 'ID').!

tableForITINERARY: aTable 
    (aTable createFieldNamed: 'ID' type: platform serial)
    	bePrimaryKey.
    aTable createFieldNamed: 'RES_ID' type: (platform int4)!

tableForPASSENGER: aTable
    | |
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20)! !

!GlorpDemoDescriptorSystem methodsFor: 'other'!

allTableNames
    ^#('GR_ADDRESS' 'PERSON' 'GR_CUSTOMER' 'BANK_TRANS' 'BANK_ACCT' 'CUSTOMER_ACCT_LINK' 'EMAIL_ADDRESS' 'STUFF' 'PASSENGER' 'AIRLINE' 'FREQUENT_FLYER' 'COMPRESSED_MONEY_TABLE' 'RESERVATION' 'ITINERARY' 'TRANSFORMED_TIME' 'FKCONTACT' 'FKADDRESS').!

constructAllClasses
    ^(super constructAllClasses)
    	add: GlorpPerson;
    	add: GlorpAddress;
    	add: GlorpCustomer;
    	add: GlorpBankTransaction;
    	add: GlorpBankAccount;
    	add: GlorpMoney;
    	add: GlorpCompressedMoney;
    	add: GlorpServiceCharge;
    	add: GlorpBankAccountNumber;
    	add: GlorpEmailAddress;
    	add: GlorpPassenger;
    	add: GlorpAirline;
    	add: GlorpReservation;
    	add: GlorpItinerary;
    	add: GlorpTransformedTime;
    	yourself! !

!GlorpDemoDescriptorSystem class methodsFor: 'accessing'!

default
    Default isNil ifTrue: [Default := self new].
    ^Default! !

!GlorpDemoDescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpWorkerDescriptorSystem methodsFor: 'descriptors'!

descriptorForGlorpJob: aDescriptor 
    "Note that the job table contains a FINISHED field, but the GlorpJob object doesn't. This field is determined only by membership in the finished or pending collections. In this particular case it's not very useful from a domain perspective, but it's interesting to be able to map. Similarly, whether a job is priority or not is not in the domain object, and is stored in the link table defining the relationship"

    | table |
    table := self tableNamed: 'GLORP_JOB'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id
    			to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #description
    			to: (table fieldNamed: 'DESCRIPTION')).!

descriptorForGlorpWorker: aDescriptor 
    | table linkTable |
    table := self tableNamed: 'GLORP_WORKER'.
    aDescriptor table: table.
    aDescriptor 
    	addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor 
    	addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: ((OneToManyMapping new)
    			attributeName: #pendingJobs;
    			referenceClass: GlorpJob;
    			mappingCriteria: (self workerCriteriaWithConstant: 'N' in: table)).
    aDescriptor addMapping: ((OneToManyMapping new)
    			attributeName: #finishedJobs;
    			referenceClass: GlorpJob;
    			mappingCriteria: (self workerCriteriaWithConstant: 'Y' in: table)).
    linkTable := self tableNamed: 'GLORP_WORKER_JOB_LINK'.

    "Note that priorityJobs may include finished jobs as well, and instances may occur in both this collection and the other two"
    aDescriptor addMapping: ((ManyToManyMapping new)
    			attributeName: #priorityJobs;
    			referenceClass: GlorpJob;
    			mappingCriteria: (Join 
    						from: (table fieldNamed: 'ID')
    						to: (linkTable fieldNamed: 'WORKER_ID')
    						from: 'Y'
    						to: (linkTable fieldNamed: 'PRIORITY'))).!

workerCriteriaWithConstant: aString in: table 
    ^Join 
    	from: (table fieldNamed: 'ID')
    	to: ((self tableNamed: 'GLORP_JOB') fieldNamed: 'OWNER_ID')
    	from: aString
    	to: ((self tableNamed: 'GLORP_JOB') fieldNamed: 'FINISHED').! !

!GlorpWorkerDescriptorSystem methodsFor: 'examples'!

exampleJobRow: anInteger finished: aBoolean
    | table row |
    table := self tableNamed: 'GLORP_JOB'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'ID') put: anInteger.
    row at: (table fieldNamed: 'DESCRIPTION') put: 'Job ', anInteger printString.
    row at: (table fieldNamed: 'FINISHED') put: (aBoolean ifTrue: ['Y'] ifFalse: ['N']).
    row at: (table fieldNamed: 'OWNER_ID') put: 1234.

    ^row.!

exampleLinkRow1
    | table row |
    table := self tableNamed: 'GLORP_WORKER_JOB_LINK'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'WORKER_ID') put: 1234.
    row at: (table fieldNamed: 'JOB_ID') put: 2.
    row at: (table fieldNamed: 'PRIORITY') put: 'N'.
    ^row.!

exampleLinkRow2
    | table row |
    table := self tableNamed: 'GLORP_WORKER_JOB_LINK'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'WORKER_ID') put: 1234.
    row at: (table fieldNamed: 'JOB_ID') put: 3.
    row at: (table fieldNamed: 'PRIORITY') put: 'Y'.
    ^row.!

exampleWorkerRow
    | table row |
    table := self tableNamed: 'GLORP_WORKER'.
    row := DatabaseRow newForTable: table.
    row at: (table fieldNamed: 'ID') put: 1234.
    row at: (table fieldNamed: 'NAME') put: 'John Worker'.
    ^row.! !

!GlorpWorkerDescriptorSystem methodsFor: 'other'!

allTableNames
    ^#('GLORP_WORKER' 'GLORP_JOB' 'GLORP_WORKER_JOB_LINK').!

constructAllClasses
    ^(super constructAllClasses)
    	add: GlorpJob;
    	add: GlorpWorker;
    	yourself! !

!GlorpWorkerDescriptorSystem methodsFor: 'tables'!

tableForGLORP_JOB: aTable
    | ownerId |
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'DESCRIPTION' type: (platform varChar: 40).
    aTable createFieldNamed: 'FINISHED' type: (platform varChar: 1).
    ownerId := aTable createFieldNamed: 'OWNER_ID' type: platform int4.
    aTable addForeignKeyFrom: ownerId
    	to: ((self tableNamed: 'GLORP_WORKER') fieldNamed: 'ID').!

tableForGLORP_WORKER: aTable
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).!

tableForGLORP_WORKER_JOB_LINK: aTable
    | workerId jobId |
    workerId := aTable createFieldNamed: 'WORKER_ID' type: platform int4.
    aTable addForeignKeyFrom: workerId
    	to: ((self tableNamed: 'GLORP_WORKER') fieldNamed: 'ID').
    jobId := aTable createFieldNamed: 'JOB_ID' type: platform int4.
    aTable addForeignKeyFrom: jobId
    	to: ((self tableNamed: 'GLORP_JOB') fieldNamed: 'ID').
    aTable createFieldNamed: 'PRIORITY' type: (platform varChar: 1).! !

!GlorpWorkerDescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpCollectionTypesDescriptorSystem methodsFor: 'tables'!

linkTable
    ^self tableNamed: 'GR_THING_LINK'.!

ownerTable
    ^self tableNamed: 'GR_THINGWITHCOLLECTIONS'.!

tableForGR_THINGONE: aTable
    | setOwnerId arrayOwnerId |
    (aTable createFieldNamed: 'ID' type: platform serial) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    setOwnerId := aTable createFieldNamed: 'SET_OWNER' type: platform int4.
    aTable addForeignKeyFrom: setOwnerId
    	to: (self ownerTable fieldNamed: 'ID').

    arrayOwnerId := aTable createFieldNamed: 'ARRAY_OWNER' type: platform int4.
    aTable addForeignKeyFrom: arrayOwnerId
    	to: (self ownerTable fieldNamed: 'ID').
    aTable createFieldNamed: 'ARRAY_POSITION' type: platform int4.!

tableForGR_THINGWITHCOLLECTIONS: aTable
    (aTable createFieldNamed: 'ID' type: platform serial) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).!

tableForGR_THING_LINK: aTable
    | ownerId thingId |
    ownerId := aTable createFieldNamed: 'OWNER_ID' type: platform int4.
    aTable addForeignKeyFrom: ownerId to: (self ownerTable fieldNamed: 'ID').
    thingId := aTable createFieldNamed: 'THING_ID' type: platform int4.
    aTable
    	addForeignKeyFrom: thingId
    	to: (self thingOneTable fieldNamed: 'ID').
    aTable createFieldNamed: 'TYPE' type: (platform char: 1).
    aTable createFieldNamed: 'POSITION' type: platform int4.!

thingOneTable
    ^self tableNamed: 'GR_THINGONE'.! !

!GlorpCollectionTypesDescriptorSystem methodsFor: 'descriptors'!

descriptorForGlorpThingOne: aDescriptor 
    aDescriptor table: self thingOneTable.
    aDescriptor addMapping: (DirectMapping from: #id to: (self thingOneTable fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (self thingOneTable fieldNamed: 'NAME')).!

descriptorForGlorpThingWithLotsOfDifferentCollections: aDescriptor
    | ocMapping |
    aDescriptor table: self ownerTable.
    aDescriptor
    	addMapping:
    		(DirectMapping from: #id to: (self ownerTable fieldNamed: 'ID')).
    aDescriptor
    	addMapping:
    		(DirectMapping from: #name to: (self ownerTable fieldNamed: 'NAME')).
    aDescriptor
    	addMapping:
    		((OneToManyMapping new)
    			attributeName: #array;
    			referenceClass: GlorpThingOne;
    			collectionType: Array;
    			orderBy: [:each | (each getTable: self thingOneTable) getField: 'ARRAY_POSITION'];
    			writeTheOrderField;
    			mappingCriteria:
    					(Join
    							from: (self ownerTable fieldNamed: 'ID')
    							to: (self thingOneTable fieldNamed: 'ARRAY_OWNER'))).
    aDescriptor
    	addMapping:
    		((OneToManyMapping new)
    			attributeName: #set;
    			referenceClass: GlorpThingOne;
    			collectionType: Set;
    			mappingCriteria:
    					(Join
    							from: (self ownerTable fieldNamed: 'ID')
    							to: (self thingOneTable fieldNamed: 'SET_OWNER'))).
    ocMapping := ((ManyToManyMapping new)
    			attributeName: #orderedCollection;
    			referenceClass: GlorpThingOne;
    			collectionType: OrderedCollection;
    			mappingCriteria:
    					(Join
    							from: (self ownerTable fieldNamed: 'ID')
    							to: (self linkTable fieldNamed: 'OWNER_ID')
    							from: 'O'
    							to: (self linkTable fieldNamed: 'TYPE'))).
    ocMapping orderBy: [:each | (each getTable: self linkTable) getField: 'POSITION'].
    ocMapping writeTheOrderField.
    aDescriptor addMapping: ocMapping.

    aDescriptor
    	addMapping:
    		((ManyToManyMapping new)
    			attributeName: #bag;
    			referenceClass: GlorpThingOne;
    			collectionType: Bag;
    			mappingCriteria:
    					(Join
    							from: (self ownerTable fieldNamed: 'ID')
    							to: (self linkTable fieldNamed: 'OWNER_ID')
    							from: 'B'
    							to: (self linkTable fieldNamed: 'TYPE'))).
    aDescriptor
    	addMapping:
    		((ManyToManyMapping new)
    			attributeName: #sortedCollection;
    			referenceClass: GlorpThingOne;
    			collectionType: SortedCollection;
    			mappingCriteria:
    					(Join
    							from: (self ownerTable fieldNamed: 'ID')
    							to: (self linkTable fieldNamed: 'OWNER_ID')
    							from: 'S'
    							to: (self linkTable fieldNamed: 'TYPE'))).! !

!GlorpCollectionTypesDescriptorSystem methodsFor: 'accessing'!

allTableNames
    ^#('GR_THINGWITHCOLLECTIONS' 'GR_THINGONE' 'GR_THING_LINK').!

constructAllClasses
    ^super constructAllClasses add: GlorpThingWithLotsOfDifferentCollections; add: GlorpThingOne; yourself.! !

!GlorpJob methodsFor: 'accessing'!

description
    ^description!

description: anObject
    description := anObject!

id
    ^id!

id: anObject
    id := anObject! !

!GlorpJob class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpressionTest methodsFor: 'tests'!

testAndOperation
    | expression fred base |
    fred := 'Fred'.
    base := BaseExpression new.
    expression := [:a | (a firstName = fred) & (a firstName ~= fred)] asGlorpExpressionOn: base.
    self assert: expression class == RelationExpression.
    self assert: expression relation = #AND.!

testAndOperation2
    | expression fred base |
    fred := 'Fred'.
    base := BaseExpression new.
    expression := [:a | (a firstName = fred) AND: (a firstName ~= fred)] asGlorpExpressionOn: base.
    self assert: expression class == RelationExpression.
    self assert: expression relation = #AND.!

testAnySatisfy
    | expression |
    expression := [:a | a items anySatisfy: [:each | each id = 7]] asGlorpExpression.
    self assert: expression class == CollectionExpression.
    self assert: expression leftChild == expression rightChild leftChild base.!

testAnySatisfyPrint
    | expression command |
    expression := [:cust | cust transactions anySatisfy: [:each | each id = 7]] 
    			asGlorpExpressionForDescriptor: (system descriptorFor: GlorpCustomer).
    command := GlorpNullCommand useBinding: false platform: system platform.
    expression printSQLOn: command withParameters: Dictionary new.
    self assert: command sqlString = '(BANK_TRANS.ID = 7)'!

testBetweenAnd
    | expression base |
    base := BaseExpression new.
    expression := [:a | a between: 3 and: 4] asGlorpExpressionOn: base.
    self assert: expression class == RelationExpression.
    self assert: expression relation = #AND.
    self assert: expression leftChild relation == #>.
    self assert: expression leftChild rightChild value == 3.
    self assert: expression rightChild relation == #<.
    self assert: expression rightChild rightChild value == 4.!

testEqualityOperation
    | expression fred base |
    fred := 'Fred'.
    base := BaseExpression new.
    expression := [:a | a firstName = fred] asGlorpExpressionOn: base.
    self assert: expression leftChild == (base get: #firstName).
    self assert: expression rightChild class == ConstantExpression.
    self assert: expression rightChild value == fred.
    self assert: expression relation == #=!

testFindingMapping
    | base baseDescriptor |
    baseDescriptor := system descriptorFor: GlorpBankTransaction.
    base := BaseExpression new descriptor: baseDescriptor.
    self assert: (base get: #serviceCharge) mapping == (baseDescriptor mappingForAttributeNamed: #serviceCharge).
    self assert: (base get: #serviceCharge) sourceDescriptor == (system descriptorFor: GlorpBankTransaction).
    self assert: (base get: #serviceCharge) descriptor == (system descriptorFor: GlorpServiceCharge)!

testIsNullPrint
    | expression stream |
    expression := [:cust | cust id = nil]
    	asGlorpExpressionForDescriptor: (system descriptorFor: GlorpCustomer).
    stream := WriteStream on: (String new: 100).
    expression printSQLOn: stream withParameters: Dictionary new.
    self assert: stream contents = '(GR_CUSTOMER.ID IS NULL)'.!

testJoinOperation
    | userExpression base expression addressTable personTable query field1 field2 join |
    addressTable := system tableNamed: 'GR_ADDRESS'.
    personTable := system tableNamed: 'PERSON'.
    base := BaseExpression new.
    base descriptor: (system descriptorFor: GlorpPerson).
    userExpression := [:aPerson | aPerson address number = 12] 
    			asGlorpExpressionOn: base.
    query := SimpleQuery returningOneOf: GlorpPerson where: userExpression.
    query session: (GlorpSession new system: system).
    self assert: (userExpression additionalExpressionsIn: query) size = 1.
    query prepare.
    expression := query criteria.
    self assert: query joins size = 1.
    join := query joins first.
    self
    	assert: expression == userExpression;
    	assert: expression relation == #=.
    field1 := join leftChild field.
    self assert: field1 table parent == personTable.
    self assert: field1 name = 'ADDRESS_ID'.
    field2 := join rightChild field.
    self assert: field2 table parent == addressTable.
    self assert: field2 name = 'ID'.!

testMappingBase
    | base |
    base := BaseExpression new.
    self assert: (base get: #someAttribute) base == base!

testMappingExpressionIdentity
 
    self assertIdentityOf: [:a | a someAttribute] and: [:a | a someAttribute].!

testMappingExpressionIdentity2
    self assertIdentityOf: [:a | a perform: #someAttribute] and: [:a | a someAttribute].!

testMappingExpressionIdentity3
    self assertIdentityOf: [:a | a get: #someAttribute] and: [:a | a someAttribute].!

testMappingExpressionIdentity4
    self denyIdentityOf: [:a | a get: #someAttribute] and: [:a | a someOtherAttribute].!

testNotNullPrint
    | expression stream |
    expression := [:cust | cust id ~= nil]
    	asGlorpExpressionForDescriptor: (system descriptorFor: GlorpCustomer).
    stream := WriteStream on: (String new: 100).
    expression printSQLOn: stream withParameters: Dictionary new.
    self assert: stream contents = '(GR_CUSTOMER.ID IS NOT NULL)'.!

testOrOperation
    | expression fred base |
    fred := 'Fred'.
    base := BaseExpression new.
    expression := [:a | (a firstName = fred) | (a firstName ~= fred)] asGlorpExpressionOn: base.
    self assert: expression class == RelationExpression.
    self assert: expression relation = #OR.!

testOrOperation2
    | expression fred base |
    fred := 'Fred'.
    base := BaseExpression new.
    expression := [:a | (a firstName = fred) OR: (a firstName ~= fred)] asGlorpExpressionOn: base.
    self assert: expression class == RelationExpression.
    self assert: expression relation = #OR.!

testTwoLevelMappingExpressionIdentity
    self assertIdentityOf: [:a | a someAttribute someAttribute] and: [:a | a someAttribute someAttribute].
    self denyIdentityOf: [:a | a someAttribute someAttribute] and: [:a | a someAttribute].! !

!GlorpExpressionTest methodsFor: 'support'!

assertIdentityOf: aBlock and: anotherBlock
    
 	| base |
    base := BaseExpression new.
    self assert: (aBlock asGlorpExpressionOn: base) == (anotherBlock asGlorpExpressionOn: base)!

denyIdentityOf: aBlock and: anotherBlock
 
    | base |
    base := BaseExpression new.
    self deny: (aBlock asGlorpExpressionOn: base) == (anotherBlock asGlorpExpressionOn: base)! !

!GlorpExpressionTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpFakeElementBuilder methodsFor: 'element builder protocol'!

valueOf: aField
    ^value.!

valueOfField: aField in: anArray
    ^value.! !

!GlorpFakeElementBuilder methodsFor: 'accessing'!

value: anObject
    value := anObject.! !

!GlorpFakeElementBuilder class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPerson methodsFor: 'accessing'!

address
    "Private - Answer the value of the receiver's ''address'' instance variable."

    ^address!

address: anObject
    "Private - Set the value of the receiver's ''address'' instance variable to the argument, anObject."

    address := anObject!

emailAddresses
    ^emailAddresses!

emailAddresses: aCollection
    emailAddresses := aCollection!

id
    "Private - Answer the value of the receiver's ''id'' instance variable."

    ^id!

id: anObject
    "Private - Set the value of the receiver's ''id'' instance variable to the argument, anObject."

    id := anObject!

name
    "Private - Answer the value of the receiver's ''name'' instance variable."

    ^name!

name: anObject
    "Private - Set the value of the receiver's ''name'' instance variable to the argument, anObject."

    name := anObject! !

!GlorpPerson methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '('.
    aStream nextPutAll: id printString, ',', name printString.
    aStream nextPutAll: ')'.! !

!GlorpPerson class methodsFor: 'examples'!

example1
    ^self new
    	id: 1;
    	name: 'Zaphod Beeblebrox';
    	address: GlorpAddress example1.!

example1WithChangedAddress
    ^self new
    	id: 1;
    	name: 'Zaphod Beeblebrox';
    	address: GlorpAddress example1WithChangedAddress.!

example1WithDifferentAddress
    ^self new
    	id: 1;
    	name: 'Zaphod Beeblebrox';
    	address: GlorpAddress example2.!

example1WithDifferentName
    ^self new
    	id: 1; 
    	name: 'John Doe';
    	address: GlorpAddress example1.!

example1WithNoAddress
    ^self new
    	id: 1;
    	name: 'Zaphod Beeblebrox';
    	address: nil.!

example2
    ^self new
    	id: 2;
    	name: 'John Doe';
    	address: GlorpAddress example2.! !

!GlorpPerson class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTableTest methodsFor: 'tests'!

testBasicSequencing
    | row |
    row := DatabaseRow newForTable: (system tableNamed: 'STUFF').
    row preWriteAssignSequencesUsing: nil.
    row postWriteAssignSequencesUsing: nil.
    self assert: (row at: ((system tableNamed: 'STUFF') fieldNamed: 'ID')) = 1.!

testCircularFieldRefs
    | field table1 table2 |
    table1 := DatabaseTable named: 'BAR'.
    field := table1 createFieldNamed: 'FOO' type: dbPlatform int4.
    table2 := DatabaseTable named: 'BLETCH'.
    table1 addForeignKeyFrom: field to: (table2 createFieldNamed: 'FLIRP' type: dbPlatform int4).
    self assert: (table2 fieldNamed: 'FLIRP') = table1 foreignKeyConstraints first targetField.!

testConstraintCreation
    | constraint |
    constraint := ForeignKeyConstraint 
    	sourceField: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'BANK_CODE')
    	targetField: ((system tableNamed: 'PERSON') fieldNamed: 'ID').
    self assert: constraint creationString = 
    	 'CONSTRAINT BANK_ACCT__TO_PERSON_ID_REF FOREIGN KEY (BANK_CODE) REFERENCES PERSON (ID)'.
    self assert: constraint dropString = 
    	 'ALTER TABLE BANK_ACCT DROP CONSTRAINT BANK_ACCT__TO_PERSON_ID_REF'.
    constraint := ForeignKeyConstraint 
    	sourceField: ((system tableNamed: 'BANK_ACCT') fieldNamed: 'BANK_CODE')
    	targetField: ((system tableNamed: 'PERSON') fieldNamed: 'ID')
    	suffixExpression: 'ON DELETE CASCADE'.
    self assert: constraint creationString = 'CONSTRAINT BANK_ACCT__TO_PERSON_ID_REF FOREIGN KEY (BANK_CODE) REFERENCES PERSON (ID) ON DELETE CASCADE'.
    self assert: constraint dropString = 'ALTER TABLE BANK_ACCT DROP CONSTRAINT BANK_ACCT__TO_PERSON_ID_REF'.!

testFieldTable
    | field table |
    field := DatabaseField named: 'FOO' type: dbPlatform int4.
    table := DatabaseTable named: 'BAR'.
    table addField: field.
    self assert: (table fieldNamed: 'FOO') = field.!

testPrimaryKeyFields
    | pkFields table |
    table := system tableNamed: 'BANK_TRANS'.
    pkFields := table primaryKeyFields.
    self assert: pkFields size = 1.
    self assert: (pkFields at: 1) == (table fieldNamed: 'ID').!

testPrimaryKeyFields2
    | table field |
    table := DatabaseTable new.
    field := (DatabaseField named: 'FRED' type: (dbPlatform varChar: 10))
    	bePrimaryKey.
    table addField: field.
    self assert: table primaryKeyFields size = 1.
    self assert: (table primaryKeyFields at: 1) == field.!

testPrimaryKeyFieldsNoPK
    | pkFields table |
    table := system tableNamed: 'CUSTOMER_ACCT_LINK'.
    pkFields := table primaryKeyFields.
    self assert: pkFields size = 0.!

testPrintingWithoutParent
    | t t1 |
    t := system tableNamed: 'GR_CUSTOMER'.
    self assert: t sqlTableName = 'GR_CUSTOMER'.!

testPrintingWithParent
    | t t1 |
    t := system tableNamed: 'GR_CUSTOMER'.
    t1 := t copy.
    t1 parent: t.
    t1 name: 'foo'.
    self assert: t1 sqlTableName = 'GR_CUSTOMER foo'.!

testRowCreation
    | row |
    row := system examplePersonRow1.
    self assert: (row at: (row table fieldNamed: 'ID')) = 3.!

testTwoSequences
    | row1 row2 table idField |
    table := system tableNamed: 'STUFF'.
    row1 := DatabaseRow newForTable: table.
    row2 := DatabaseRow newForTable: table.
    row1 preWriteAssignSequencesUsing: nil.
    row1 postWriteAssignSequencesUsing: nil.
    row2 preWriteAssignSequencesUsing: nil.
    row2 postWriteAssignSequencesUsing: nil.
    idField := table fieldNamed: 'ID'.
    self assert: (row1 at: idField) = 1.
    self assert: (row2 at: idField) = 2.! !

!GlorpTableTest methodsFor: 'support'!

setUp
    super setUp.
    descriptors := system allDescriptors.
    dbPlatform := MySQLPlatform new.
    InMemorySequenceDatabaseType reset! !

!GlorpTableTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpEncyclopediaEntry methodsFor: 'accessing'!

id: aSmallInteger 
    id := aSmallInteger.!

name: aString 
    name := aString!

text: aString 
    text := aString.! !

!GlorpEncyclopediaEntry class methodsFor: 'examples'!

example1
    ^self new
    	id: 1;
    	name: 'One';
    	text: 'The first number (not counting zero)'.!

example2
    ^self new
    	id: 2;
    	name: 'Two';
    	text: 'The second number (comes after 1)'.! !

!GlorpEncyclopediaEntry class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpAirline methodsFor: 'accessing'!

id
    ^id!

id: anInteger
    id := anInteger!

name
    ^name!

name: aString
    name := aString! !

!GlorpAirline class methodsFor: 'examples'!

example1
    ^self new
    	id: 73;
    	name: 'Air Canada'.!

example2
    ^self new
    	id: 74;
    	name: 'Lufthansa'.! !

!GlorpAirline class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpWritingTest methodsFor: 'tests'!

testRegistrationFromWrittenObject
    | customer trans transactions |
    session beginTransaction.
    [customer := GlorpCustomer new.
    customer name: 'foo'.
     customer id: 123.
    session beginUnitOfWork.
    session register: customer.
    session commitUnitOfWork.
    trans := GlorpBankTransaction new.
    session beginUnitOfWork.
    session readOneOf: GlorpCustomer where: [:each | each id = customer id].
    customer addTransaction: trans.
    session commitUnitOfWork.
    transactions := session accessor executeSQLString: 'SELECT ID FROM BANK_TRANS WHERE OWNER_ID = ', customer id printString.
    self assert: transactions size = 1.
    self assert: (trans id = (transactions first atIndex: 1))]
    	ensure: [session rollbackTransaction].! !

!GlorpWritingTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpWritingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpEncyclopediaDescriptorSystem methodsFor: 'descriptors'!

descriptorForGlorpEncyclopedia: aDescriptor 
    | table keyMapping valueMapping entryTable |
    table := self tableNamed: 'ENCYC'.
    entryTable := self tableNamed: 'ENCYC_ENTRY'.
    aDescriptor table: table.

    keyMapping := DirectMapping new field: (entryTable fieldNamed: 'NAME').
    valueMapping := OneToManyMapping new
    		referenceClass: GlorpEncyclopediaEntry;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: (entryTable fieldNamed: 'OWNER_ID')).
    aDescriptor addMapping: (DictionaryMapping 
    	attributeName: #entries
    	keyMapping: keyMapping
    	valueMapping: valueMapping).

    ^aDescriptor!

descriptorForGlorpEncyclopediaEntry: aDescriptor 
    | entryTable |
    entryTable := self tableNamed: 'ENCYC_ENTRY'.
    aDescriptor table: entryTable.
    aDescriptor addMapping: (DirectMapping from: #id to: (entryTable fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (entryTable fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #text to: (entryTable fieldNamed: 'ENTRY_TEXT')).

    ^aDescriptor.! !

!GlorpEncyclopediaDescriptorSystem methodsFor: 'other'!

allTableNames
    ^#().
"	^#('ENCYC' 'ENCYC_ENTRY')."!

constructAllClasses
    ^(super constructAllClasses)
    	add: GlorpEncyclopedia;
    	add: GlorpEncyclopediaEntry;
    	yourself! !

!GlorpEncyclopediaDescriptorSystem methodsFor: 'tables'!

tableForENCYC: aTable 
    (aTable newFieldNamed: 'ID') beNumeric; bePrimaryKey.!

tableForENCYC_ENTRY: aTable 
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'ENTRY_TEXT' type: (platform varChar: 20).! !

!GlorpEncyclopediaDescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpNullCommand methodsFor: 'accessing'!

sqlString
    ^stream contents.! !

!GlorpNullCommand methodsFor: 'initializing'!

initialize
    stream := WriteStream on: (String new: 100).! !

!GlorpNullCommand class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpNullCommand class methodsFor: 'instance creation'!

useBinding: aBoolean platform: aDatabasePlatform
    ^(self new)
    	useBinding: aBoolean;
    	platform: aDatabasePlatform;
    	yourself.! !

!GlorpConstantValueInRelationshipTest methodsFor: 'support'!

idsFor: aCollection
    ^(aCollection collect: [:each | each id]) asSortedCollection asArray.!

sampleWorker
    | worker job3 |
    worker := GlorpWorker new.
    worker id: 1234.
    worker name: 'Some Worker'.
    worker pendingJobs add: (GlorpJob new id: 1; description: 'job 1').
    worker pendingJobs add: (GlorpJob new id: 2; description: 'job 2').
    worker finishedJobs add: (job3 := GlorpJob new id: 3; description: 'job 3').
    worker finishedJobs add: (GlorpJob new id: 4; description: 'job 4').
    worker priorityJobs add: job3.
    ^worker.!

setUp
    system := GlorpWorkerDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database.
    session := GlorpSessionResource current newSession.
    session system: system.!

writeTestData
    session writeRow: system exampleWorkerRow.
    session writeRow: (system exampleJobRow: 1 finished: false).
    session writeRow: (system exampleJobRow: 2 finished: false).
    session writeRow: (system exampleJobRow: 3 finished: true).
    session writeRow: (system exampleJobRow: 4 finished: true).
    session writeRow: system exampleLinkRow1.
    session writeRow: system exampleLinkRow2.! !

!GlorpConstantValueInRelationshipTest methodsFor: 'tests'!

testRead
    | worker |
    [session beginTransaction.
    self writeTestData.
    worker := session execute: (Query returningOneOf: GlorpWorker where: [:each | each id = 1234]).

    self assert: (self idsFor: worker pendingJobs) = #(1 2).
    self assert: (self idsFor: worker finishedJobs) = #(3 4).
    self assert: (self idsFor: worker priorityJobs) = #(3).

    ] ensure: [session rollbackTransaction].!

testWrite
    | worker sampleWorker |
    [session beginTransaction.
    session beginUnitOfWork.
    sampleWorker := self sampleWorker.
    session register: sampleWorker.
    session commitUnitOfWork.
    session reset.
    worker := session execute: (Query returningOneOf: GlorpWorker where: [:each | each id = 1234]).

    self assert: (self idsFor: worker pendingJobs) = #(1 2).
    self assert: (self idsFor: worker finishedJobs) = #(3 4).
    self assert: (self idsFor: worker priorityJobs) = #(3).

    ] ensure: [session rollbackTransaction].! !

!GlorpConstantValueInRelationshipTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource.! !

!GlorpConstantValueInRelationshipTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpUnitOfWorkTest methodsFor: 'support'!

exampleCustomerProxy
    | p |
    p := Proxy new.
    p session: session.
    p query: (GlorpQueryStub returningOneOf: GlorpCustomer where: [:a | a id = 3]).
    p query result: (GlorpCustomer new id: 3).
    ^p!

exampleCustomerWithTransactionsProxy
    | customer |
    customer := GlorpCustomer new.
    customer transactions: self exampleTransactionsProxy.
    ^customer!

exampleTransactionsProxy
    | p |
    p := Proxy new.
    p session: session.
    p query: (GlorpQueryStub returningOneOf: GlorpBankTransaction where: [:a | a id ~= 0]).
    p query result: (Array with: GlorpBankTransaction example1 with: GlorpBankTransaction example1).
    ^p!

exampleTransactionWithCustomerProxy
    | transaction |
    transaction := GlorpBankTransaction example1.
    transaction owner: self exampleCustomerProxy.
    ^transaction!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpUnitOfWorkTest methodsFor: 'tests'!

testAutomaticRegistrationOnRead
    | p c |
    p := self exampleCustomerProxy.
    c := p getValue.
    session beginUnitOfWork.
    session register: p.
    self assert: (session isRegistered: p).
    self assert: (session isRegistered: c).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction isRegistered: p).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction isRegistered: c).!

testCheckIfInstantiationRequiredForDirectMapping
    | c1 mapping proxy |
    c1 := GlorpCustomer new.
    proxy := Proxy new.
    c1 name: proxy.
    session beginUnitOfWork.
    session register: c1.
    mapping := (session descriptorFor: GlorpCustomer) mappingForAttributeNamed: #name.
    self deny: (session privateGetCurrentUnitOfWork checkIfInstantiationRequiredFor: c1 mapping: mapping).!

testCheckIfInstantiationRequiredForRelationshipInstantiatedProxy
    | c1 mapping proxy |
    c1 := GlorpCustomer new.
    proxy := Proxy new.
    proxy query: (GlorpQueryStub new session: session; result: 'foo').
    proxy session: session.
    proxy yourself.
    c1 accounts: proxy.
    session beginUnitOfWork.
    session register: c1.
    c1 accounts: #().
    mapping := (session descriptorFor: GlorpCustomer) mappingForAttributeNamed: #accounts.
    self deny: (session privateGetCurrentUnitOfWork checkIfInstantiationRequiredFor: c1 mapping: mapping).!

testCheckIfInstantiationRequiredForRelationshipNoChange
    | c1 mapping proxy |
    c1 := GlorpCustomer new.
    proxy := Proxy new.
    c1 accounts: proxy.
    session beginUnitOfWork.
    session register: c1.
    mapping := (session descriptorFor: GlorpCustomer) mappingForAttributeNamed: #accounts.
    self deny: (session privateGetCurrentUnitOfWork checkIfInstantiationRequiredFor: c1 mapping: mapping).!

testCheckIfInstantiationRequiredForRelationshipNoProxy
    | c1 mapping |
    c1 := GlorpCustomer new.
    c1 accounts: #().
    session beginUnitOfWork.
    session register: c1.
    c1 accounts: nil.
    mapping := (session descriptorFor: GlorpCustomer) mappingForAttributeNamed: #accounts.
    self deny: (session privateGetCurrentUnitOfWork checkIfInstantiationRequiredFor: c1 mapping: mapping).!

testCheckIfInstantiationRequiredForRelationshipWithChange
    | c1 mapping proxy |
    c1 := GlorpCustomer new.
    proxy := Proxy new.
    proxy session: session.
    proxy query: (GlorpQueryStub new result: 'foo').
    c1 accounts: proxy.
    session beginUnitOfWork.
    session register: c1.
    c1 accounts: #().
    mapping := (session descriptorFor: GlorpCustomer) mappingForAttributeNamed: #accounts.
    self assert: (session privateGetCurrentUnitOfWork checkIfInstantiationRequiredFor: c1 mapping: mapping).!

testCommitOrderAtSessionLevel
    | tables | 
    tables := session tablesInCommitOrder.
    tables first name = 'CUSTOMER'.
    self unfinished.!

testOriginalValueFor
    | c1 mapping |
    c1 := GlorpCustomer new.
    c1 name: 'fred'.
    session beginUnitOfWork.
    session register: c1.
    c1 name: 'barney'.
    mapping := (session descriptorFor: GlorpCustomer) mappingForAttributeNamed: #name.
    self assert: (session privateGetCurrentUnitOfWork originalValueFor: c1 mapping: mapping) = 'fred'.!

testPostRegister
    | c1 t1 t2 |
    c1 := GlorpCustomer example2.
    [session beginTransaction.
    session beginUnitOfWork.
    t1 := GlorpBankTransaction new.
    t2 := GlorpBankTransaction new.
    c1 addTransaction: t1.
    c1 addTransaction: t2.
    session register: c1.
    self assert: (session isRegistered: c1).
    self assert: (session isRegistered: t1).
    self assert: (session isRegistered: t2).
    session commitUnitOfWork]
    	ensure: [session rollbackTransaction].
    "Need some assertions on what was written"
    self unfinished.!

testPreRegister
    
    | c1 t1 t2 trans |
    c1 := GlorpCustomer example2.
    [session beginTransaction.
    session beginUnitOfWork.
    session register: c1.
    t1 := GlorpBankTransaction new.
    t2 := GlorpBankTransaction new.
    c1 addTransaction: t1.
    c1 addTransaction: t2.
    trans := session privateGetCurrentUnitOfWork privateGetTransaction.
    session commitUnitOfWork.
    self assert: (trans isRegistered: c1).
    self assert: (trans isRegistered: t1).
    self assert: (trans isRegistered: t2).]
    	ensure: [session rollbackTransaction].
    "Need some assertions on what got written"
    self unfinished.!

testRegisterCollection
    | c1 c2 collection |
    c1 := GlorpCustomer new.
    c2 := GlorpCustomer new.
    session beginUnitOfWork.
    collection := Array with: c1 with: c2.
    session register: collection.
    self assert: (session isRegistered: c1).
    self assert: (session isRegistered: collection).!

testRegisterExistingCollection
    | c1 |
    c1 := GlorpCustomer new.
    session beginUnitOfWork.
    session register: c1.
    session register: c1 transactions.
    self assert: (session isRegistered: c1).
    self assert: (session isRegistered: c1 transactions).
    self deny: (session isNew: c1 transactions).!

testRegisterInstantiatedProxy
    | p c |
    p := self exampleCustomerProxy.
    c := p getValue.
    session beginUnitOfWork.
    session register: p.
    self assert: (session isRegistered: p).
    self assert: (session isRegistered: c).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction isRegistered: p).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction isRegistered: c).!

testRegisterObjectWithCollectionProxyThenInstantiate
    | customer transactions |
    customer := self exampleCustomerWithTransactionsProxy.
    session beginUnitOfWork.
    session register: customer.
    self deny: customer transactions isInstantiated.
    transactions := customer transactions getValue.
    self assert: customer transactions isInstantiated.
    session register: transactions.
    self assert: (session isRegistered: transactions first).
    self assert: (session isRegistered: customer).
    self assert: (session isRegistered: transactions).
    self assert: (session isRegistered: customer transactions).!

testRegisterObjectWithInstantiatedProxy
    | transaction customer |
    transaction := self exampleTransactionWithCustomerProxy.
    customer := transaction owner getValue.
    session beginUnitOfWork.
    session register: transaction.
    self assert: (session isRegistered: transaction).
    self assert: (session isRegistered: customer).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: transaction).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: customer).
    self assert: transaction owner isInstantiated.!

testRegisterObjectWithNilCollection
    | c1 |
    c1 := GlorpCustomer new.
    c1 transactions: nil.
    session beginUnitOfWork.
    session register: c1.
    self assert: (session isRegistered: c1).!

testRegisterObjectWithProxy
    | transaction |
    transaction := self exampleTransactionWithCustomerProxy.
    session beginUnitOfWork.
    session register: transaction.
    self assert: (session isRegistered: transaction).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: transaction).
    self deny: transaction owner isInstantiated.!

testRegisterObjectWithProxyThenInstantiate
    | transaction customer |
    transaction := self exampleTransactionWithCustomerProxy.
    session beginUnitOfWork.
    session register: transaction.
    self deny: transaction owner isInstantiated.
    customer := transaction owner getValue.
    session register: transaction.
    self assert: (session isRegistered: transaction).
    self assert: (session isRegistered: customer).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: transaction).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: customer).
    self assert: transaction owner isInstantiated!

testRegisterObjectWithProxyThenInstantiateAndReregister
    | transaction customer |
    transaction := self exampleTransactionWithCustomerProxy.
    session beginUnitOfWork.
    session register: transaction.
    customer := transaction owner getValue.
    session register: transaction.
    self assert: (session isRegistered: transaction).
    self assert: (session isRegistered: customer).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: transaction).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: customer).
    self assert: transaction owner isInstantiated!

testRegisterProxy
    | p |
    p := self exampleCustomerProxy.
    session beginUnitOfWork.
    session register: p.
    self deny: (session isRegistered: p).
    self deny: (session isRegistered: p query result).
    p getValue.
    self assert: (session isRegistered: p).
    self assert: (session isRegistered: p query result).!

testRegisterProxyThenInstantiateAndReregister
    | p c |
    p := self exampleCustomerProxy.
    session beginUnitOfWork.
    session register: p.
    c := p getValue.
    session register: p.
    self assert: (session isRegistered: p).
    self assert: (session isRegistered: c).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: p).
    self assert: (session privateGetCurrentUnitOfWork privateGetTransaction 
    			isRegistered: c)!

testRollbackOneToManyAfterAdd
    | customer t1 t2 transList amount |
    customer := GlorpCustomer example1.
    t1 := customer transactions first.
    t2 := customer transactions last.
    transList := customer transactions.
    amount := t1 amount.
    session beginUnitOfWork.
    session register: customer.
    20 timesRepeat: [customer addTransaction: (GlorpBankTransaction new)].
    customer transactions first amount: 65543.
    session rollbackUnitOfWork.
    self assert: customer transactions == transList.
    self assert: customer transactions size = 2.
    self assert: customer transactions first == t1.
    self assert: customer transactions last == t2.
    self assert: t1 amount == amount.!

testRollbackOneToManyAfterReplace
    | customer t1 t2 transList |
    customer := GlorpCustomer example1.
    t1 := customer transactions first.
    t2 := customer transactions last.
    transList := customer transactions.
    session beginUnitOfWork.
    session register: customer.
    customer transactions: OrderedCollection new.
    session rollbackUnitOfWork.
    self assert: customer transactions == transList.
    self assert: customer transactions size = 2.
    self assert: customer transactions first == t1.
    self assert: customer transactions last == t2.!

testRollbackOneToManyProxy
    | customer t1 t2 transList |
    customer := GlorpCustomer example1.
    t1 := customer transactions first.
    t2 := customer transactions last.
    transList := customer transactions.
    session beginUnitOfWork.
    session register: customer.
    customer transactions: OrderedCollection new.
    session rollbackUnitOfWork.
    self assert: customer transactions == transList.
    self assert: customer transactions size = 2.
    self assert: customer transactions first == t1.
    self assert: customer transactions last == t2.!

testRollbackOneToManyWithList
    "Check that dependents aren't being registered for the collection"
    | customer marker |
    "Lists only exist in VW"
    Dialect isVisualWorks ifFalse: [^self].
    marker := Object new.
    customer := GlorpCustomer example1.
    customer transactions: (customer transactions asList).
    customer transactions addDependent: marker.
    session beginUnitOfWork.
    session register: customer.
    20 timesRepeat: [customer addTransaction: (GlorpBankTransaction new)].
    session rollbackUnitOfWork.
    self assert: customer transactions class == (Dialect smalltalkAt: #List).
    self assert: customer transactions size = 2.
    self should: [customer transactions privateAt: 3] raise: Object subscriptOutOfBoundsSignal.
    self assert: (customer transactions dependents includes: marker).
    self deny: (session isRegistered: marker).!

testRollbackOneToOne
    | transaction customer |
    transaction := GlorpBankTransaction new.
    customer := GlorpCustomer new.
    transaction owner: customer.
    session beginUnitOfWork.
    session register: transaction.
    transaction owner: GlorpCustomer new.
    session rollbackUnitOfWork.
    self assert: transaction owner == customer.!

testRollbackOneToOneWithProxy
    | transaction customerProxy |
    transaction := self exampleTransactionWithCustomerProxy.
    customerProxy := transaction owner.
    session beginUnitOfWork.
    session register: transaction.
    transaction owner: GlorpCustomer new.
    session rollbackUnitOfWork.
    self assert: transaction owner == customerProxy!

testWriteObjectWithNilCollection
    | c1 query customer |
    c1 := GlorpCustomer new.
    c1 transactions: nil.
    c1 id: 9999.
    [session beginTransaction.
    session beginUnitOfWork.
    session register: c1.
    session commitUnitOfWork.
    query := Query returningOneOf: GlorpCustomer where: [:each | each id = 9999].
    query shouldRefresh: true.
    customer := session execute: query.
    self assert: customer transactions notNil.
    self assert: customer transactions isEmpty.
    ]
    	ensure: [session rollbackTransaction].! !

!GlorpUnitOfWorkTest methodsFor: 'tests-transaction wrappers'!

testInTransactionDoSuccessful
    "This has to test that a transaction completed successfully, so unlike most other tests, we have to clean up the evidence afterwards"

    | result |
    [session inTransactionDo: [
    	session writeRow: session system exampleAddressRow].
    result := session readManyOf: GlorpAddress.
    self assert: result size = 1.
    self assert: result first id = 123]
    	ensure: [session accessor executeSQLString: 'DELETE FROM GR_ADDRESS'].!

testInTransactionDoUnsuccessful
    "This has to test that a transaction completed successfully, so unlike most other tests, we have to clean up the evidence afterwards"

    | result |
    [session inTransactionDo: [
    	session writeRow: session system exampleAddressRow.
    	self error: 'no you don''t']] on: Error do: [:ex | ex return: nil].
    result := session readManyOf: GlorpAddress.
    self assert: result size = 0.!

testinUnitOfWorkSuccessful
    | result |
    [session beginTransaction.
    session inUnitOfWorkDo: [
    	session register: (GlorpReservation new id: 345)].
    result := session readManyOf: GlorpReservation.
    self assert: result size = 1.
    self assert: result first id = 345]
    	ensure: [session rollbackTransaction].!

testinUnitOfWorkUnsuccessful
    | result |
    [session beginTransaction.
    [session inUnitOfWorkDo: [
    	session register: (GlorpReservation new id: 345).
    	self error: 'aaaagh']] on: Error do: [:ex | ex return: nil].
    result := session readManyOf: GlorpReservation.
    self assert: result size = 0]
    	ensure: [session rollbackTransaction].!

testTransactSuccessful
    "This has to test that a transaction completed successfully, so unlike most other tests, we have to clean up the evidence afterwards"

    | result |
    [session transact: [
    	session register: (GlorpReservation new id: 345)].
    result := session readManyOf: GlorpReservation.
    self assert: result size = 1.
    self assert: result first id = 345]
    	ensure: [session accessor executeSQLString: 'DELETE FROM RESERVATION'].!

testTransactUnsuccessful
    | result |
    [session transact: [
    	session register: (GlorpReservation new id: 345).
    	self error: 'didn''t work']] on: Error do: [:ex | ex return: nil].
    result := session readManyOf: GlorpReservation.
    self assert: result size = 0.! !

!GlorpUnitOfWorkTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpUnitOfWorkTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpMockAccessor methodsFor: 'executing'!

executeSQLString: aString
    ^#((3)).! !

!GlorpMockAccessor class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTypeTestsModelClass methodsFor: 'As yet unclassified'!

test
    ^test.!

test: anObject
    test:= anObject.! !

!GlorpTypeTestsModelClass class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpItinerary methodsFor: 'accessing'!

id
    ^id!

id: anObject
    id := anObject!

reservation
    ^reservation!

reservation: anObject
    reservation := anObject! !

!GlorpItinerary class methodsFor: 'examples'!

example1
    ^self new
    	id: 23;
    	reservation: GlorpReservation example1.!

example2
    ^self new
    	id: 27;
    	reservation: GlorpReservation example2.! !

!GlorpItinerary class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPassenger methodsFor: 'accessing'!

airline
    ^airline.!

airline: anAirline
    airline := anAirline.!

frequentFlyerPoints
    ^frequentFlyerMiles.!

frequentFlyerPoints: aSmallInteger 
    frequentFlyerMiles := aSmallInteger.!

id
    ^id!

id: aSmallInteger 
    id := aSmallInteger.!

name
    ^name.!

name: aString 
    name := aString.! !

!GlorpPassenger class methodsFor: 'examples'!

example1
    ^self new
    	id: 3;
    	name: 'Some Passenger';
    	frequentFlyerPoints: 10000;
    	airline: GlorpAirline example1.!

example2
    ^self new
    	id: 39;
    	name: 'Some Other Passenger';
    	frequentFlyerPoints: 7;
    	airline: GlorpAirline example2.! !

!GlorpPassenger class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDictionaryMappingTest methodsFor: 'tests'!

testCasesToWrite
    "How des a dictionary mapping relate to 1:many vs many:many.
    dictionary of strings to strings
    dictionary of strings to objects
    dictionary of objects to objects
    keys always have to be related to values somehow, because I can't extract the association otherwise. Both might also be associated to source.
    You should be able to use the topological sort to determine the create/delete order of tables as well"!

testStringToObject
    | encyclopedia rowMap entryTable entries |
    encyclopedia := GlorpEncyclopedia example1.
    entries := encyclopedia entries asOrderedCollection.
    entryTable := system tableNamed: 'ENCYC_ENTRY'.
    rowMap := RowMap new.
"	(system descriptorFor: Encyclopedia) createRowsFor: encyclopedia in: rowMap.

    self assert: (rowMap includesRowForTable: entryTable withKey: entries first).
    self assert: rowMap size = 3."

    "So what happens here. We need to know how the rows for the associations get created. Do we treat the associations as objects (risking loss of identity issues in some dictionary implementations), create composite keys similar to many-many, or what?"! !

!GlorpDictionaryMappingTest methodsFor: 'support'!

setUp
    system := GlorpEncyclopediaDescriptorSystem  forPlatform: GlorpDatabaseLoginResource defaultLogin database.! !

!GlorpDictionaryMappingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpReadingTest methodsFor: 'tests'!

testConversionOnConstantQueryParams
    | query result transRow | 
    
    [| |
    session beginTransaction.
    transRow := session system exampleBankTransactionRow.
    session writeRow: transRow.
    query := Query returningManyOf: GlorpBankTransaction where: [:trans | trans amount currency = #CDN].
    result := session execute: query.
    self assert: result size = 1.
    self assert: result first amount amount = 7] 
    		ensure: [session rollbackTransaction]!

testConversionOnConstantQueryParams2
    | query result transRow |
    
    [| |
    session beginTransaction.
    transRow := session system exampleBankTransactionRow.
    session writeRow: transRow.
    query := Query returningManyOf: GlorpBankTransaction where: [:trans | trans amount amount = 7].
    result := session execute: query.
    self assert: result size = 1.
    self assert: result first amount amount = 7] 
    		ensure: [session rollbackTransaction]!

testNonIntrusiveAlsoFetch
    | alsoFetchQuery query results | 

    "If a platform has no outer joins (!) we cannot execute
     this test."
    (session system platform supportsANSIJoins or: [
	session system platform useMicrosoftOuterJoins or: [
	session system platform useOracleOuterJoins ]])
	    ifFalse: [ ^self ].

    [session beginTransaction.
    session beginUnitOfWork.
    session register: GlorpPerson example1.
    session register: (GlorpPerson example1
    						id: 2;
    						address: nil;
    						yourself).
    session commitUnitOfWork.
    alsoFetchQuery := Query
    					returningManyOf: GlorpPerson
    					where: nil.
    alsoFetchQuery alsoFetch: [:ea | ea address asOuterJoin].
    query := Query
    				returningManyOf: GlorpPerson
    				where: nil.
    results := alsoFetchQuery executeIn: session.
    self assert: results size = 2.
    results := query executeIn: session.
    self assert: results size = 2] 
    		ensure: [session rollbackTransaction].!

testReadAccountsWithCompoundAnySatisfy
    | query result |
    
    [| block |
    session beginTransaction.
    self writeCustomer1Rows.
    block := 
    		[:account | 
    		account accountHolders anySatisfy: [:each | (each id = 27) & (each name = 'aCustomer')]].
    query := Query returningManyOf: GlorpBankAccount where: block.
    result := session execute: query.
    self assert: result size = 2] 
    		ensure: [session rollbackTransaction]!

testReadAccountsWithMultipleAnySatisfy
    | query result |
     
    [| block |
    session beginTransaction.
    self writeCustomer1Rows.
    block := 
    		[:account | 
    		(account accountHolders anySatisfy: [:each | each id = 24]) 
    			| (account accountHolders anySatisfy: [:each | each id = 27])].
    query := Query returningManyOf: GlorpBankAccount where: block.
    result := session execute: query.
    self assert: result size = 2] 
    		ensure: [session rollbackTransaction]!

testReadAccountsWithNestedAnySatisfy
    | query result |
    [| block |
    session beginTransaction.
    self writeCustomer1RowsWithTransactions.
    block := 
    		[:account | 
    		account accountHolders anySatisfy: [:each | each transactions anySatisfy: [:eachTrans |
    		eachTrans id ~= nil]]].
    query := Query returningManyOf: GlorpBankAccount where: block.
    result := session execute: query.
    self assert: result size = 2] 
    		ensure: [session rollbackTransaction]!

testReadAddress
    | object query results rowToWrite |
    
    [session beginTransaction.
    rowToWrite := session system exampleAddressRow.
    session writeRow: rowToWrite.
    query := Query returningManyOf: GlorpAddress
    			where: [:address | address id = 123].
    results := query executeIn: session] 
    		ensure: [session rollbackTransaction].
    self assert: results size = 1.
    object := results first.
    self assert: object class = GlorpAddress.
    self assert: object id = 123.
    self assert: object street = 'Paseo Montril'.
    self assert: object number = '10185'!

testReadAddressProxy
    | object query results rowToWrite proxy | 

    [session beginTransaction.
    	rowToWrite := session system exampleAddressRow.
    	session writeRow: rowToWrite.
    	query := (Query
    		returningManyOf: GlorpAddress
    		where: ([:address | address id = 123]) ) returnProxies: true.
    	results := query executeIn: session.
    	self assert: (results size = 1).
    	proxy := results first.
    	object := proxy getValue]
    ensure: [session rollbackTransaction].

    self assert: (proxy class = Proxy).
    self assert: (object class = GlorpAddress).
    self assert: (object id = 123).
    self assert: (object street = 'Paseo Montril').
    self assert: (object number = '10185').!

testReadAddressProxyAlreadyInMemory
    "Check that if the object is already in memory we don't create a proxy for it, just return the instance"
    | object query results rowToWrite |

    [session beginTransaction.
    	rowToWrite := session system exampleAddressRow.
    	session writeRow: rowToWrite.
    	session readOneOf: GlorpAddress where: [:address | address id = 123].
    	Dialect garbageCollect.
    	(Delay forSeconds: 10) wait.
    	query := (Query
    		returningManyOf: GlorpAddress
    		where: ([:address | address id = 123]) ) returnProxies: true.
    	results := query executeIn: session.
    	self assert: (results size = 1).
    	object := results first]
    ensure: [session rollbackTransaction].

    self assert: (object class = GlorpAddress).
    self assert: (object id = 123).
    self assert: (object street = 'Paseo Montril').
    self assert: (object number = '10185').!

testReadAdHoc 
    | queryTime table row time idField times |
    
    [
    session beginTransaction.
    
    table := session system tableNamed: 'TRANSFORMED_TIME'.
    row := DatabaseRow newForTable: table.
    idField := (table fieldNamed: 'ID').
    row at: idField put: 3.
    time := Time now.
    row at: (table fieldNamed: 'TIMEFIELD') put: time asSeconds.

    session writeRow: row.
    queryTime := GlorpTransformedTime  new id: 3; time: time.
    times := session readManyOf: GlorpTransformedTime where: [:each | each time = time].
    self assert: times size = 1.
    self assert: times first time = time.
    ] 
    		ensure: [session rollbackTransaction]!

testReadAllAddress
    | object results rowToWrite |
    
    [session beginTransaction.
    rowToWrite := session system exampleAddressRow.
    session writeRow: rowToWrite.
    results := session readManyOf: GlorpAddress] 
    		ensure: [session rollbackTransaction].
    self assert: results size = 1.
    object := results first.
    self assert: object class = GlorpAddress.
    self assert: object id = 123.
    self assert: object street = 'Paseo Montril'.
    self assert: object number = '10185'!

testReadCompressedMoney
    | object query results rowToWrite |
    
    [session beginTransaction.
    rowToWrite := session system exampleCompressedMoneyRow.
    session writeRow: rowToWrite.
    query := Query returningManyOf: GlorpCompressedMoney
    			where: [:money | money id ~= 0].
    results := query executeIn: session] 
    		ensure: [session rollbackTransaction].
    self assert: results size = 1.
    object := results first.
    self assert: object class = GlorpCompressedMoney.
    self assert: object amount = 12.
    self assert: object currency = 'CDN'.!

testReadCustomerAndAddTransaction
    | query  customer accountIds newCustomer rawRows |
    
    [session beginTransaction.
    accountIds := self writeCustomer1Rows.
    session beginUnitOfWork.
    query := Query returningOneOf: GlorpCustomer
    			where: [:person | person id = 27].
    customer := session execute: query.
    customer addTransaction: GlorpBankTransaction example1.
    session commitUnitOfWork.
    newCustomer := session execute: query.
    self assert: customer == newCustomer.
    self assert: customer transactions first owner yourself == customer.
    rawRows := session accessor executeSQLString: 'SELECT ID, NAME FROM GR_CUSTOMER'.
    self assert: rawRows size = 1.
    self assert: (rawRows first atIndex: 1) = 27.
    ] 
    		ensure: [session rollbackTransaction]!

testReadCustomerWithAccounts
    | query id1 id2 result accounts backRef1 backRef2 accountIds |
    
    [session beginTransaction.
    accountIds := self writeCustomer1Rows.
    id1 := accountIds at: 1.
    id2 := accountIds at: 2.
    query := Query returningOneOf: GlorpCustomer
    			where: [:person | person id = 27].
    result := session execute: query.
    self assert: result seenPostFetch = true.
    accounts := result accounts getValue.
    self assert: accounts size = 2.
    self assert: (accounts first id = id1 or: [accounts last id = id1]).
    self assert: (accounts first id = id2 or: [accounts last id = id2]).
    self assert: accounts first id ~= accounts last id.
    backRef1 := accounts first accountHolders getValue.
    self assert: backRef1 size = 1.
    self assert: backRef1 first = result.
    backRef2 := accounts first accountHolders getValue.
    self assert: backRef2 size = 1.
    self assert: backRef2 first = result] 
    		ensure: [session rollbackTransaction]!

testReadCustomerWithAnySatisfy
    | query result accounts |
    
    [session beginTransaction.
    self writeCustomer1Rows.
    query := Query returningManyOf: GlorpCustomer
    			where: 
    				[:person | 
    				person accounts anySatisfy: [:each | each accountNumber branchNumber > 0]].
    result := session execute: query.
    self assert: result size = 1.
    accounts := result first accounts getValue.
    self assert: accounts size = 2.
    query := Query returningManyOf: GlorpCustomer
    			where: 
    				[:person | 
    				person accounts anySatisfy: [:each | each accountNumber branchNumber = 2]].
    result := session execute: query.
    self assert: result size = 1.
    accounts := result first accounts getValue.
    self assert: accounts size = 2] 
    		ensure: [session rollbackTransaction]!

testReadCustomerWithMultipleAnySatisfy
    | query result |
    
    [| block |
    session beginTransaction.
    self writeCustomer1Rows.
    block := 
    		[:person | 
    		(person accounts anySatisfy: [:each | each accountNumber branchNumber = 2]) 
    			& (person accounts 
    					anySatisfy: [:each | each accountNumber branchNumber = 3])].
    query := Query returningManyOf: GlorpCustomer where: block.
    result := session execute: query.
    self assert: result size = 1] 
    		ensure: [session rollbackTransaction]!

testReadEmbeddedObjectDirectly
    | serviceCharges transRow |
    
    [
    session beginTransaction.
    transRow := session system exampleBankTransactionRow.
    session writeRow: transRow.
    transRow := session system exampleBankTransactionRow2.
    session writeRow: transRow.
    serviceCharges := session readManyOf: GlorpServiceCharge.
    self assert: serviceCharges size = 2.
    self deny: serviceCharges first == serviceCharges last.
    ] 
    		ensure: [session rollbackTransaction]!

testReadEmbeddedOneToOne
    self helperForTestReadEmbeddedOneToOne.!

testReadMultiFieldAdHoc
    | object query results rowToWrite row2 |
    
    [session beginTransaction.
    rowToWrite := session system exampleCompressedMoneyRow.
    row2 := session system exampleCompressedMoneyRow2.
    session writeRow: rowToWrite.
    session writeRow: row2.

    query := Query returningManyOf: GlorpCompressedMoney
    			where: [:money | money array = #('CDN' 12)].
    results := query executeIn: session] 
    		ensure: [session rollbackTransaction].
    self assert: results size = 1.
    object := results first.
    self assert: object class = GlorpCompressedMoney.
    self assert: object amount = 12.
    self assert: object currency = 'CDN'.!

testReadMultipleObjectsManyToMany1
    | query result account |
    
    [session beginTransaction.
    self writeCustomer1Rows.

    query := Query returningManyOf: GlorpBankAccount.
    query alsoFetch: [:each | each accountHolders].
    result := query executeIn: session.
    self assert: result size = 2.
    account := result first.
    self deny: account accountHolders class == Proxy.
    self assert: account accountHolders size = 1.
    self assert: (account accountHolders first == (result last accountHolders first))] 
    		ensure: [session rollbackTransaction]!

testReadMultipleObjectsManyToMany2
    | query result customer |
    
    [session beginTransaction.
    self writeCustomer1Rows.

    query := Query returningManyOf: GlorpCustomer.
    query retrieve: [:each | each ].
    query alsoFetch: [:each | each accounts].
    result := query executeIn: session.
    self assert: result size = 1.
    customer := result first.
    self deny: customer accounts class == Proxy.
    self assert: customer accounts size = 2] 
    		ensure: [session rollbackTransaction]!

testReadMultipleObjectsToManyTwoLevels
    | query result account transactions |
    
    [session beginTransaction.
    self writeCustomer1Rows.
    session beginUnitOfWork.
    query := Query returningOneOf: GlorpCustomer
    			where: [:person | person id = 27].
    account := session execute: query.
    account addTransaction: (GlorpBankTransaction new amount: (GlorpMoney new amount: 1; currency: #CDN)).
    account addTransaction: (GlorpBankTransaction new amount: (GlorpMoney new amount: 2; currency: #CDN)).
    session commitUnitOfWork.
    session initializeCache.
    "Phew. Done setup"

    query := Query returningManyOf: GlorpBankAccount.
    query alsoFetch: [:each | each accountHolders].
    query alsoFetch: [:each | each accountHolders transactions].
    result := query executeIn: session.
    self assert: result size = 2.
    account := result first.
    self deny: account accountHolders class == Proxy.
    self assert: account accountHolders size = 1.
    transactions := account accountHolders first transactions.
    self deny: transactions class == Proxy.
    self assert: transactions size = 2.
    self assert: account accountHolders first == (result at: 2) accountHolders first] 
    		ensure: [session rollbackTransaction]!

testReadPassenger
    | passengerRow1 passengerRow2 query result |
    
    [session beginTransaction.
    passengerRow1 := session system examplePassengerRow.
    session writeRow: passengerRow1.
    passengerRow2 := session system exampleFrequentFlyerRow.
    session writeRow: passengerRow2.
    query := Query returningOneOf: GlorpPassenger
    			where: [:passenger | passenger id = 1].
    result := query executeIn: session.
    self assert: result id = 1.
    self assert: result name = 'Some Passenger'.
    self assert: result frequentFlyerPoints = 10000] 
    		ensure: [session rollbackTransaction]!

testReadReservationWithJoinToPassenger
    | reservations |
    
    [session beginTransaction.
    self writeReservationData.
    session beginUnitOfWork.
    reservations := session readManyOf: GlorpReservation
    			where: [:each | each passenger id = 3].
    self assert: reservations size = 1.
    self assert: reservations first passengers size = 1.] 
    		ensure: [session rollbackTransaction]!

testReadReservationWithPassenger
    
    | reservation passenger reservations |
    [session beginTransaction.
    self writeReservationData.
    session beginUnitOfWork.
    "This doesn't validate so well. We want to make sure that the passenger table read uses a join and gets back only the one row, but it's hard to test that. Putting in an error check in the query for readOne... that returns multiple would work, but is kind of intrusive"
    reservations := session readManyOf: GlorpReservation where: [:each | each id = 2].
    self assert: reservations size = 1.
    reservation := reservations first.
    passenger := reservation passenger.
    passenger id.
    ] 
    		ensure: [session rollbackTransaction]!

testReadWithCacheHits
    | query addressRow result1 result2 |
    
    [session beginTransaction.
    addressRow := session system exampleAddressRow.
    session writeRow: addressRow.
    query := Query returningOneOf: GlorpAddress
    			where: [:address | address id = 123].
    result1 := query executeIn: session.
    result2 := query executeIn: session.
    self assert: result1 == result2] 
    		ensure: [session rollbackTransaction]!

testReadWithFalseWhereClause
    | query id1 id2 result accountIds |
    
    [session beginTransaction.
    accountIds := self writeCustomer1Rows.
    id1 := accountIds at: 1.
    id2 := accountIds at: 2.
    query := Query returningManyOf: GlorpBankAccount
    			where: false.
    result := session execute: query.
    self assert: result size = 0] 
    		ensure: [session rollbackTransaction]!

testReadWithNilWhereClause
    | query id1 id2 result accountIds |
    
    [session beginTransaction.
    accountIds := self writeCustomer1Rows.
    id1 := accountIds at: 1.
    id2 := accountIds at: 2.
    query := Query returningManyOf: GlorpBankAccount
    			where: nil.
    result := session execute: query.
    self assert: result size = 2] 
    		ensure: [session rollbackTransaction]!

testReadWithTrueWhereClause
    | query id1 id2 result accountIds |
    
    [session beginTransaction.
    accountIds := self writeCustomer1Rows.
    id1 := accountIds at: 1.
    id2 := accountIds at: 2.
    query := Query returningManyOf: GlorpBankAccount
    			where: true.
    result := session execute: query.
    self assert: result size = 2] 
    		ensure: [session rollbackTransaction]!

testRegisteringWithEmbeddedMapping
    | bankTrans |
    session beginUnitOfWork.
    bankTrans := self helperForTestReadEmbeddedOneToOne.
    self assert: (session isRegistered: bankTrans).
    self assert: (session isRegistered: bankTrans serviceCharge).
    self assert: (session isRegistered: bankTrans serviceCharge amount).!

testSequencePolicyForInsert
    | testObject |

    InMemorySequenceDatabaseType reset.
    [session beginTransaction.
    session beginUnitOfWork.
    testObject := GlorpAirline new.
    session register: testObject.
    session commitUnitOfWork.
    self assert: testObject id = 1]
    	ensure: [session rollbackTransaction]! !

!GlorpReadingTest methodsFor: 'support'!

checkRefreshDoing: aBlock
    "Check that we refresh correctly doing the action specified by aBlock"
    | rowToWrite address modifiedRow |
    
    [session beginTransaction.
    rowToWrite := session system exampleAddressRow.
    session writeRow: rowToWrite.
    address := session readOneOf: GlorpAddress
    			where: [:each | each id = 123].
    modifiedRow := session system exampleModifiedAddressRow.
    modifiedRow owner: address. "Otherwise it thinks it's an insert"
    session writeRow: modifiedRow.
    aBlock value: address.
    self assert: address street = 'Something Else'.] 
    		ensure: [session rollbackTransaction].!

helperForTestReadEmbeddedOneToOne
    | transRow query result |
    
    [session beginTransaction.
    transRow := session system exampleBankTransactionRow.
    session writeRow: transRow.
    query := Query returningOneOf: GlorpBankTransaction
    			where: [:each | each id = each id].
    result := query executeIn: session] 
    		ensure: [session rollbackTransaction].
    self assert: result serviceCharge notNil.
    self assert: result serviceCharge description = 'additional overcharge'.
    self assert: result amount currency = #CDN.
    self assert: result amount amount = 7.
    self assert: result serviceCharge amount currency = #USD.
    self assert: result serviceCharge amount amount = 2.
    ^result.!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    system := session system.!

tearDown
    super tearDown.
    session reset.
    session := nil.
    system := nil.!

writeCustomer1Rows
    | id1 id2 customerRow accountRow1 accountRow2 linkRow1 linkRow2 |

    customerRow := session system exampleCustomerRow1.
    accountRow1 := session system exampleAccountRow1. 
    accountRow2 := session system exampleAccountRow2.
    linkRow1 := session system exampleCALinkRow1.
    linkRow2 := session system exampleCALinkRow2.
    session writeRow: customerRow.
    session writeRow: accountRow1.
    session writeRow: accountRow2.
    session writeRow: linkRow1.
    session writeRow: linkRow2.

    id1 := accountRow1 at: (accountRow1 table fieldNamed: 'ID').
    id2 := accountRow2 at: (accountRow2 table fieldNamed: 'ID').
    ^Array with: id1 with: id2.!

writeCustomer1RowsWithTransactions
    | table row aGlorpDemoDescriptorSystem |
    self writeCustomer1Rows.
    aGlorpDemoDescriptorSystem := session system.
    table := aGlorpDemoDescriptorSystem tableNamed: 'BANK_TRANS'.
    row := DatabaseRow newForTable: table.
    row atFieldNamed: 'ID' put: nil.
    row atFieldNamed: 'AMT_CURR' put: 'CDN'.
    row atFieldNamed: 'AMT_AMT' put: 7.
    row atFieldNamed: 'SRVC_DESC' put: 'additional overcharge'.
    row atFieldNamed: 'SRVC_AMT_CURR' put: 'USD'.
    row atFieldNamed: 'SRVC_AMT_AMT' put: 2.
    row atFieldNamed: 'OWNER_ID' put: 27.
    session writeRow: row.!

writeReservationData
    session beginUnitOfWork.
    session register: GlorpItinerary example1.
    session register: GlorpItinerary example2.
    session commitUnitOfWork.
    session writeRow: session system examplePassengerRow.
    session initializeCache! !

!GlorpReadingTest methodsFor: 'tests-refreshing'!

testNonRefreshAddress
    "Test that if we don't set the refresh flag on the query we don't re-read the data"
    | query rowToWrite address modifiedRow |
    
    [session beginTransaction.
    rowToWrite := session system exampleAddressRow.
    session writeRow: rowToWrite.
    address := session readOneOf: GlorpAddress
    			where: [:each | each id = 123].
    modifiedRow := session system exampleModifiedAddressRow.
    modifiedRow owner: address. "Otherwise it thinks it's an insert"
    session writeRow: modifiedRow.
    query := Query returningOneOf: GlorpAddress where: [:each | each id = 123].
    query executeIn: session.
    self assert: address street = 'Paseo Montril'.] 
    		ensure: [session rollbackTransaction].!

testRefreshAddress
    "Check that we refresh correctly when the refresh flag is set"
    | query rowToWrite address modifiedRow |
    
    [session beginTransaction.
    rowToWrite := session system exampleAddressRow.
    session writeRow: rowToWrite.
    address := session readOneOf: GlorpAddress
    			where: [:each | each id = 123].
    modifiedRow := session system exampleModifiedAddressRow.
    modifiedRow owner: address. "Otherwise it thinks it's an insert"
    session writeRow: modifiedRow.
    query := Query returningOneOf: GlorpAddress where: [:each | each id = 123].
    query shouldRefresh: true.
    query executeIn: session.
    self assert: address street = 'Something Else'.] 
    		ensure: [session rollbackTransaction].!

testSessionRefresh
    "Check that we refresh correctly when the refresh flag is set"
    self checkRefreshDoing: [:anAddress | session refresh: anAddress].!

testSessionRefreshOnExpiry
    "Check that we refresh correctly when an object has expired"
    | cachePolicy |
    cachePolicy := TimedExpiryCachePolicy new.
    cachePolicy timeout: 0.
    cachePolicy expiryAction: #refresh.
    (session descriptorFor: GlorpAddress) cachePolicy: cachePolicy.
    self checkRefreshDoing: [:anAddress |
    	session readOneOf: GlorpAddress where: [:each | each id = 123]].!

testSessionRefreshOnExpiryWithCacheLookupOnly
    "Check that we refresh correctly when an object has expired, doing only a cache lookup, not an explicit read"
    | cachePolicy |
    cachePolicy := TimedExpiryCachePolicy new.
    cachePolicy timeout: 0.
    cachePolicy expiryAction: #refresh.
    (session descriptorFor: GlorpAddress) cachePolicy: cachePolicy.
    self checkRefreshDoing: [:anAddress |
    	session privateGetCache lookupClass: GlorpAddress key: 123 ifAbsent: [nil]].! !

!GlorpReadingTest methodsFor: 'tests-in'!

testInFromJoin
    | query result |
    [session beginTransaction.
    self writeReservationData.
    query := Query returningManyOf: GlorpItinerary where: [:each | each reservation passengers 
    	anySatisfy: [:eachPassenger | eachPassenger airline id in: #(73 74)]].
    result := session execute: query.
    self assert: (result allSatisfy: [:each | each reservation passengers anySatisfy: [:eachPassenger | #(73 74) includes: eachPassenger airline id]]).
    self assert: result size = 2] ensure: [session rollbackTransaction].! !

!GlorpReadingTest methodsFor: 'accessing'!

session
    ^session.! !

!GlorpReadingTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource with: GlorpDemoTablePopulatorResource.! !

!GlorpReadingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabasePlatformTest methodsFor: 'tests'!

testReadTimestamp
    | ts |
    ts := DatabasePlatform new readTimestamp: '2003-03-03 15:29:28.337-05' for: nil.

    self assert: ts asSeconds = 3224158168.
    self assert: ([ ts asMilliseconds = 3224158168337 ]
        on: MessageNotUnderstood
        do: [ :mnu | mnu return: mnu message selector = #asMilliseconds ]).

    ts := DatabasePlatform new readTimestamp: '2003-03-13 15:29:28.337-05' for: nil.
    self assert: ts asSeconds = 3225022168.
    self assert: ([ ts asMilliseconds = 3225022168337]
        on: MessageNotUnderstood
        do: [ :mnu | mnu return: mnu message selector = #asMilliseconds ])!

testReadTimestampNoMS
    | ts |
    ts := DatabasePlatform new readTimestamp: '2003-03-03 15:29:28-05' for: nil.
    self assert: ts year = 2003.
    self assert: ts month = 3.
    self assert: ts day = 3.
    self assert: ts hour = 15.
    self assert: ts minute = 29.
    self assert: ts second = 28.
    self assert: ([ ts milliseconds = 0 ]
        on: MessageNotUnderstood
        do: [ :mnu | mnu return: mnu message selector = #milliseconds ])!

testReadTimestampNoMSNoTZ
    | ts |
    ts := DatabasePlatform new readTimestamp: '2003-03-03 15:29:28' for: nil.
    self assert: ts year = 2003.
    self assert: ts month = 3.
    self assert: ts day = 3.
    self assert: ts hour = 15.
    self assert: ts minute = 29.
    self assert: ts second = 28.
    self assert: ([ ts milliseconds = 0 ]
        on: MessageNotUnderstood
        do: [ :mnu | mnu return: mnu message selector = #milliseconds ])!


testReadTimestampNoTZ
    | ts |
    ts := DatabasePlatform new readTimestamp: '1957-08-13 21:29:28.337' for: nil.
    self assert: ts year = 1957.
    self assert: ts month = 8.
    self assert: ts day = 13.
    self assert: ts hour = 21.
    self assert: ts minute = 29.
    self assert: ts second = 28.
    self assert: ([ ts milliseconds = 337 ]
        on: MessageNotUnderstood
        do: [ :mnu | mnu return: mnu message selector = #milliseconds ])!


testReadTimestampOverflowDays
    | ts |
    ts := DatabasePlatform new readTimestamp: '1957-08-13 21:29:28.337-05' for: nil.
    self assert: ts year = 1957.
    self assert: ts month = 8.
    self assert: ts day = 13.
    self assert: ts hour = 21.
    self assert: ts minute = 29.
    self assert: ts second = 28.
    self assert: ([ ts milliseconds = 337 ]
        on: MessageNotUnderstood
        do: [ :mnu | mnu return: mnu message selector = #milliseconds ])! !


!GlorpDatabasePlatformTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpReservation methodsFor: 'accessing'!

id
    ^id!

id: anInteger
    id := anInteger!

passenger
    ^passenger!

passenger: aPassenger
    passenger := aPassenger.
    passengers add: aPassenger.!

passengers
    ^passengers! !

!GlorpReservation methodsFor: 'initialize/release'!

initialize
    passengers := OrderedCollection new.! !

!GlorpReservation class methodsFor: 'examples'!

example1
    ^self new
    	id: 2;
    	passenger: GlorpPassenger example1.!

example2
    ^self new
    	id: 7;
    	passenger: GlorpPassenger example2.! !

!GlorpReservation class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpReservation class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDialectTest methodsFor: 'tests'!

testTimeSetMillisecond
    | time oldMs oldSec oldMin newMs |
    Dialect supportsMillisecondsInTimes ifFalse: [^self].
    time := Time now.
    oldMs := time milliseconds.
    oldSec := time seconds.
    oldMin := time minutes.
    newMs := oldMs = 999 ifTrue: [3] ifFalse: [oldMs + 1].
    time millisecond: newMs.
    self assert: time milliseconds = newMs.
    self assert: time seconds = oldSec.
    self assert: time minutes = oldMin.!

testTokensBasedOn
    self assert: (Dialect tokensBasedOn: '.' in: 'abc.def.ghi') asArray = #('abc' 'def' 'ghi').! !

!GlorpDialectTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseTypeIndividualDBTests methodsFor: 'setUp'!

createTypeTestTable
    | system |
    connection
    	dropTableNamed: 'TYPETESTS'
    	ifAbsent: [:ex | ex return: nil].
    table := DatabaseTable named: 'TYPETESTS'.
    table
    	createFieldNamed: 'test'
    	type: type.
    (table createFieldNamed: 'id' type: session system platform inMemorySequence) bePrimaryKey.
    connection
    	createTable: table
    	ifError:
    		[:ex | 
    		Transcript show: 'CANNOT CREATE TABLE'. ex pass. "<<<<<<"
      self signalFailure: ex messageText.
    		ex return: nil].
    system := self systemFor: table.
    session system: system.
    ^table.!

defaultDatabaseType
    self subclassResponsibility.!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    connection := session accessor.
    type := self defaultDatabaseType.
    table := self createTypeTestTable.!

systemFor: aTable
    | system descriptor mapping |
    system := DynamicDescriptorSystem new.
    system
    	privateTableAt: aTable name
    	put: aTable.
    descriptor := Descriptor new.
    descriptor system: system.
    descriptor describedClass: GlorpTypeTestsModelClass.
    descriptor table: aTable.
    descriptor addMapping: (DirectMapping from: #id to: (aTable fieldNamed: 'id')).
    stType isNil
    	ifTrue:
    		[mapping := DirectMapping
    			from: #test
    			to: (aTable fieldNamed: 'test')]
    	ifFalse:
    		[mapping := DirectMapping
    			from: #test
    			type: stType
    			to: (aTable fieldNamed: 'test')].
    descriptor addMapping: mapping.
    system
    	privateDescriptorAt: GlorpTypeTestsModelClass
    	put: descriptor.
    ^system.!

tearDown
    super tearDown.
    connection
    	dropTableNamed: 'TYPETESTS'
    	ifAbsent: [:ex | ex return: nil].
    session reset.
    session := nil.! !

!GlorpDatabaseTypeIndividualDBTests methodsFor: 'helpers'!

helpTestInvalidValue: anObject
    self helpTestValueWithSQLWrite: anObject
	compareModelWith: [:read :original | read isNil or: [ read test ~= original ]]
	compareWith: [:read :original | read ~= original]!

helpTestValue: anObject
    "Don't try and read back an equal float, it'll likely fail on precision issues"
    self helpTestValue: anObject
	compareModelWith: [:read :original | 
	    read notNil and: [
	        (original isKindOf: Float)
	            or: [ original class == Dialect doublePrecisionFloatClass
		    or: [ read test = original ]]]]
	compareWith: [:read :original |
	        (original isKindOf: Float)
		    or: [ read = original ] ].!

helpTestValue: anObject compareWith: aBlock
    self
	helpTestValueWithSQLWrite: anObject
	compareModelWith: [ :read :original | true ]
	compareWith: aBlock!

helpTestValue: anObject compareModelWith: modelBlock compareWith: aBlock
    self
	helpTestValueWithSQLWrite: anObject
	compareModelWith: modelBlock
	compareWith: aBlock.

    self helpTestValueWithUnitOfWorkWrite: anObject
	compareWith: modelBlock!

helpTestValueWithSQLWrite: anObject compareModelWith: modelBlock compareWith: aBlock
    | dbInValue readObject row converter dbOutValue typeTestModel system |
    system := self systemFor: table.
    session system: system.
    row := DatabaseRow newForTable: table.
    row owner: GlorpTypeTestsModelClass new.
    converter := type
    	converterForStType:
    		(stType isNil
    			ifTrue: [anObject class]
    			ifFalse: [stType]).
    dbOutValue := converter
    	convert: anObject
    	toDatabaseRepresentationAs: type.
    row
    	atFieldNamed: 'test'
    	put: dbOutValue.
    [session beginTransaction.
    session writeRow: row.
    dbInValue := ((connection executeSQLString: 'SELECT TEST, ID FROM TYPETESTS')
    	atIndex: 1) atIndex: 1.
    readObject := converter
    	convert: dbInValue
    	fromDatabaseRepresentationAs: type.

    typeTestModel := session
    	readOneOf: GlorpTypeTestsModelClass
    	where: [:each | each test = anObject ].
    self assert: (modelBlock value: typeTestModel value: anObject) ]
    	ensure: [session rollbackTransaction].
    self
    	assert:
    		(aBlock
    			value: readObject
    			value: anObject).!

helpTestValueWithUnitOfWorkWrite: anObject compareWith: aBlock
    | typeTestModel system model |
    system := self systemFor: table.
    session system: system.
    [session beginTransaction.
    session beginUnitOfWork.
    model := GlorpTypeTestsModelClass new test: anObject.
    session register: model.
    session commitUnitOfWork.
    typeTestModel := session
    	readOneOf: GlorpTypeTestsModelClass
    	where: [:each | each test = anObject].
    self assert: (aBlock value: typeTestModel value: anObject) ]
    	ensure: [session rollbackTransaction].! !

!GlorpDatabaseTypeIndividualDBTests methodsFor: 'accessing'!

platform
    ^connection platform! !

!GlorpDatabaseTypeIndividualDBTests methodsFor: 'initializing'!

initialize! !

!GlorpDatabaseTypeIndividualDBTests class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVarchar10Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform varchar: 10.! !

!GlorpVarchar10Test methodsFor: 'tests'!

testVarCharWithEscapedCharacters
    stType := String.
    self helpTestValue: nil compareWith: [:read :original |
    	self platform usesNullForEmptyStrings ifTrue: [read = ''] ifFalse: [read = nil]].
    #($~ $` $! $@ $# $$ $% $^ $& $* $( $) $_ $- $+ $= $\ $| $} ${ $] $[ $" $' $: $; $? $/ $> $. $< $,)
    	do: [:ea | self helpTestValue: 'abc' , (String with: ea) , 'def']! !

!GlorpVarchar10Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpBankAccountNumber methodsFor: 'accessing'!

accountNumber
    ^accountNumber!

accountNumber: anObject
    accountNumber := anObject!

bankCode
    ^bankCode!

bankCode: anObject
    bankCode := anObject!

branchNumber
    ^branchNumber!

branchNumber: anObject
    branchNumber := anObject! !

!GlorpBankAccountNumber class methodsFor: 'examples'!

example12345
    ^self new
    	accountNumber: 12345;
    	bankCode: 4;
    	branchNumber: 777.! !

!GlorpBankAccountNumber class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVarchar2Test methodsFor: 'tests'!

testVarChar2
    stType := String.
    self helpTestValue: nil compareWith: [:read :original |
    	self platform usesNullForEmptyStrings ifTrue: [read = ''] ifFalse: [read = nil]].
    self helpTestValue: ''.
    self helpTestValue: 'a'.
    self helpTestValue: 'ab'.
    self helpTestInvalidValue: 'abc'.
    self helpTestInvalidValue: 'abcd'.
    self helpTestInvalidValue: 'abcde'.! !

!GlorpVarchar2Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform varchar: 2.! !

!GlorpVarchar2Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpBooleanTest methodsFor: 'tests'!

testBoolean
    stType := Boolean.
    self helpTestValue: nil compareWith: [:read :original |
    	self platform usesNullForFalse ifTrue: [read = false] ifFalse: [read = nil]].
    self helpTestValue: true.
    self helpTestValue: false.! !

!GlorpBooleanTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform boolean.! !

!GlorpBooleanTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpInt4Test methodsFor: 'tests'!

testInt4
    self helpTestValue: nil.
    self helpTestValue: 3212321.! !

!GlorpInt4Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform int4! !

!GlorpInt4Test class methodsFor: 'instance creation'!

new
    "Answer a newly created and initialized instance."

    ^super new initialize! !

!GlorpInt4Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpNumericTest methodsFor: 'tests'!

testNumeric
    self helpTestValue: 12.	
    self helpTestValue: nil.
    self helpTestValue: (Dialect readFixedPointFrom: '12345678').
    self helpTestValue: 3.14  compareWith: [:read :original |
    	read - original <= 0.00001].! !

!GlorpNumericTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform numeric! !

!GlorpNumericTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTimeTest methodsFor: 'tests'!

testTime
    self helpTestValue: nil.
    self
    	helpTestValue: Time now
    	compareWith:
    		[:read :original | 
    		(read hours = original hours and: [read minutes = original minutes])
    			and: [read seconds = original seconds]].! !

!GlorpTimeTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform time! !

!GlorpTimeTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVarchar1Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform varchar: 1.! !

!GlorpVarchar1Test methodsFor: 'tests'!

testBooleanToTFString
    stType := Boolean.
    self helpTestValue: nil.
    self helpTestValue: true.
    self helpTestValue: false.! !

!GlorpVarchar1Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVarchar4Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform varchar: 4.! !

!GlorpVarchar4Test methodsFor: 'tests'!

testVarChar4
    stType := String.
    self helpTestValue: nil compareWith: [:read :original |
    	self platform usesNullForEmptyStrings ifTrue: [read = ''] ifFalse: [read = nil]].
    self helpTestValue: ''.
    self helpTestValue: 'a'.
    self helpTestValue: 'ab'.
    self helpTestValue: 'abc'.
    self helpTestValue: 'abcd'.
    stType := Symbol.
    self helpTestValue: #abcd.
    stType := nil.
    self helpTestInvalidValue: 'abcde'.! !

!GlorpVarchar4Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTextTest methodsFor: 'tests'!

testText
    self helpTestValue: nil.
    self helpTestValue: 'Now is the time for all good squeakers to come to the aid of the mouse'.! !

!GlorpTextTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform text! !

!GlorpTextTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTimestampTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform timestamp! !

!GlorpTimestampTest methodsFor: 'tests'!

testTimeStamp
    | time |
    "This has to be UTC because postgres has time zones and will try and compensate"
    time := Dialect timestampNow.
    self helpTestValue: nil.

    "MS SQL Server fails randomly because it has a resolution of 3 ms only"
    self helpTestValue: time compareWith: [:read :original |
    	(Dialect supportsMillisecondsInTimes and: [
    	    self platform supportsMillisecondsInTimes not ])
	        ifTrue: [time millisecond: 0].

	Dialect isGNU
	    ifTrue: [ (read offset: Duration zero) = (original offset: Duration zero) ]
	    ifFalse: [ read = original ] ].! !

!GlorpTimestampTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpNumeric52Test methodsFor: 'tests'!

testNumeric52
    self platform supportsVariableSizedNumerics ifFalse: [^self].
    self helpTestValue: nil.
    self helpTestValue: 12.
    self helpTestInvalidValue: 17.098.
    self helpTestValue: 3.14.! !

!GlorpNumeric52Test methodsFor: 'types'!

defaultDatabaseType
    ^(self platform numeric)
    	precision: 5;
    	scale: 2.! !

!GlorpNumeric52Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpChar2Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform char width: 2! !

!GlorpChar2Test methodsFor: 'tests'!

testChar2
    stType := String.
    self helpTestValue: nil compareWith: [:read :original |
    	self platform usesNullForEmptyStrings ifTrue: [read = ''] ifFalse: [read = nil]].
    self helpTestValue: ''.
    self helpTestValue: 'a'.
    self helpTestValue: 'ab'.
    self helpTestInvalidValue: 'abc'.
    self helpTestInvalidValue: 'abcd'.
    self helpTestInvalidValue: 'abcde'.
    
    self assert: (type typeString asUppercase = 'CHAR(2)')! !

!GlorpChar2Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpFloat4Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform float4.! !

!GlorpFloat4Test methodsFor: 'tests'!

testFloat4
    self helpTestValue: nil.
    self helpTestValue: 3.14 compareWith: [:read :original |
    	read - original <= 0.00001].! !

!GlorpFloat4Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpInt8Test methodsFor: 'tests'!

testInt8
    type := (self platform) int8.
    self helpTestValue: nil.
    self helpTestValue: 3212321555.! !

!GlorpInt8Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform int8! !

!GlorpInt8Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpChar4Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform char width: 4.! !

!GlorpChar4Test methodsFor: 'tests'!

testChar4
    stType := String.
    self helpTestValue: nil compareWith: [:read :original |
    	self platform usesNullForEmptyStrings ifTrue: [read = ''] ifFalse: [read = nil]].
    self helpTestValue: ''.
    self helpTestValue: 'a'.
    self helpTestValue: 'ab'.
    self helpTestValue: 'abc'.
    self helpTestValue: 'abcd'.
    self helpTestInvalidValue: 'abcde'.
    stType := Symbol.
    self helpTestValue: #abcd.
    
    self assert: (type typeString asUppercase= 'CHAR(4)')! !

!GlorpChar4Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpMappingTest methodsFor: 'tests'!

helperForMergedOneToOneReversingWriteOrder: aBoolean 
    | account accountTable row |
    account := GlorpBankExampleSystem new objectNumber: 1 ofClass: GlorpBankAccount.
    accountTable := system tableNamed: 'BANK_ACCT'.
    aBoolean 
    	ifTrue: 
    		[self write: account.
    		self write: account accountNumber]
    	ifFalse: 
    		[self write: account accountNumber.
    		self write: account].
    self assert: (rowMap includesRowForTable: accountTable withKey: account).
    self assert: (rowMap includesRowForTable: accountTable
    			withKey: account accountNumber).
    row := self rowFor: account.
    self assert: (row at: (accountTable fieldNamed: 'ID')) = account id.
    (Array with: row with: (self rowFor: account accountNumber)) do: 
    		[:each | 
    		self assert: (each at: (accountTable fieldNamed: 'BANK_CODE')) 
    					= account accountNumber bankCode.
    		self assert: (each at: (accountTable fieldNamed: 'BRANCH_NO')) 
    					= account accountNumber branchNumber.
    		self assert: (each at: (accountTable fieldNamed: 'ACCT_NO')) 
    					= account accountNumber accountNumber].
    self assert: (rowMap numberOfEntriesForTable: accountTable) = 2!

helperForNestedMergedOneToOneReversingWriteOrder: aBoolean 
    | trans transTable moneyTable row fieldNames fieldValues |
    trans := GlorpBankExampleSystem new objectNumber: 1
    			ofClass: GlorpBankTransaction.
    transTable := system tableNamed: 'BANK_TRANS'.
    moneyTable := system tableNamed: 'MONEY_IMAGINARY_TABLE'.
    aBoolean 
    	ifTrue: 
    		[self write: trans.
    		self write: trans amount.
    		self write: trans serviceCharge.
    		self write: trans serviceCharge amount]
    	ifFalse: 
    		[self write: trans serviceCharge amount.
    		self write: trans serviceCharge.
    		self write: trans amount.
    		self write: trans].
    self 
    	assert: (rowMap rowForTable: transTable withKey: trans) shouldBeWritten.
    self 
    	assert: (rowMap rowForTable: transTable withKey: trans serviceCharge) 
    			shouldBeWritten not.
    self 
    	assert: (rowMap rowForTable: moneyTable withKey: trans amount) 
    			shouldBeWritten not.
    self 
    	assert: (rowMap rowForTable: moneyTable withKey: trans serviceCharge amount) 
    			shouldBeWritten not.
    row := self rowFor: trans.
    self assert: (row at: (transTable fieldNamed: 'ID')) = trans id.
    fieldNames := #('AMT_CURR' 'AMT_AMT' 'SRVC_DESC' 'SRVC_AMT_CURR' 'SRVC_AMT_AMT').
    fieldValues := (Array 
    			with: trans amount currency asString
    			with: trans amount amount
    			with: trans serviceCharge description) 
    				, (Array with: trans serviceCharge amount currency asString
    						with: trans serviceCharge amount amount).
    fieldNames with: fieldValues
    	do: [:fieldName :value | self assert: (row at: (transTable fieldNamed: fieldName)) = value].
    self assert: (rowMap numberOfEntriesForTable: transTable) = 2.
    self assert: (rowMap numberOfEntriesForTable: moneyTable) = 2!

testManyToMany
    | customer customerTable accountTable linkTable linkRow |
    customer := GlorpBankExampleSystem new objectNumber: 1 ofClass: GlorpCustomer.
    rowMap := RowMap new.
    customerTable := system tableNamed: 'GR_CUSTOMER'.
    accountTable := system tableNamed: 'BANK_ACCT'.
    linkTable := system tableNamed: 'CUSTOMER_ACCT_LINK'.

    self write: customer.
    customer accounts do: [:each | 
    	self write: each].

    self assert: (rowMap includesRowForTable: customerTable withKey: customer).
    customer accounts do: [:each |
    	self assert: (rowMap includesRowForTable: accountTable withKey: each).
    	self assert: (rowMap includesRowForTable: linkTable withKey: (RowMapKey new key1: customer; key2: each))].

    customer accounts do: [:each | | rowMapKey |
    	self assert: ((self rowFor: each) at: (accountTable fieldNamed: 'ID')) = each id.
    	rowMapKey := RowMapKey new key1: customer; key2: each.
    	linkRow := rowMap rowForTable: linkTable withKey: rowMapKey.
    	self assert: (linkRow at: (linkTable fieldNamed: 'ACCT_ID')) = each id.
    	self assert: (linkRow at: (linkTable fieldNamed: 'CUSTOMER_ID')) = customer id.
    	].
    self assert: ((self rowFor: customer) at: (customerTable fieldNamed: 'ID')) = customer id.
    self assert: ((rowMap numberOfEntriesForTable: linkTable) = 2).
    self assert: ((rowMap numberOfEntriesForTable: customerTable) = 1).!

testMergedOneToOne
    self helperForMergedOneToOneReversingWriteOrder: false!

testMergedOneToOneReversingWrites
    self helperForMergedOneToOneReversingWriteOrder: true!

testMissingDescriptor
    self assert: (system descriptorFor: nil) isNil.
    self assert: (system descriptorFor: UndefinedObject) isNil.
    self assert: (system descriptorFor: 3) isNil!

testMultipleTableCreation
    
    | descriptor table passenger table2 row1 row2 |
    descriptor := system descriptorFor: GlorpPassenger.
    passenger := GlorpPassenger example1.
    rowMap := RowMap new.
    table := system existingTableNamed: 'PASSENGER'.
    table2 := system existingTableNamed: 'FREQUENT_FLYER'.
    descriptor createRowsFor: passenger in: rowMap.
    self assert: (rowMap includesRowForTable: table withKey: passenger).
    self assert: (rowMap includesRowForTable: table2 withKey: passenger).
    row1 := rowMap rowForTable: table withKey: passenger.
    self assert: (row1 at: (table fieldNamed: 'ID'))
    		= passenger id.
    self assert: (row1 at: (table fieldNamed: 'NAME'))
    		= passenger name.
    row2 := rowMap rowForTable: table2 withKey: passenger.
    self assert: (row2 at: (table2 fieldNamed: 'ID'))
    		= passenger id.
    self assert: (row2 at: (table2 fieldNamed: 'POINTS')) = passenger frequentFlyerPoints.
    self assert: rowMap numberOfEntries = 3!

testNestedMergedOneToOne
    self helperForNestedMergedOneToOneReversingWriteOrder: false!

testNestedMergedOneToOneReversingWriteOrder
    self helperForNestedMergedOneToOneReversingWriteOrder: true.!

testNilOneToOne
    
    | person  personTable addressTable |
    person := GlorpPerson example1.
    person address: nil.
    self write: person.
    self write: person address.
    personTable := system existingTableNamed: 'PERSON'.
    addressTable := system existingTableNamed: 'GR_ADDRESS'.

    self assert: (rowMap includesRowForTable: personTable withKey: person).
    self deny: (rowMap includesRowForTable: addressTable withKey: person address).

    self assert: rowMap numberOfEntries = 1.!

testOneToMany
    | customer customerTable transactionTable |
    customer := GlorpCustomer example1.
    rowMap := RowMap new.
    customerTable := system tableNamed: 'GR_CUSTOMER'.
    transactionTable := system tableNamed: 'BANK_TRANS'.
    self write: customer.
    customer transactions do: [:each |
    	self write: each].

    self assert: (rowMap includesRowForTable: customerTable withKey: customer).
    customer transactions do: [:each |
    	self assert: (rowMap includesRowForTable: transactionTable withKey: each)].

    customer transactions do: [:each |
    	self assert: ((self rowFor: each) at: (transactionTable fieldNamed: 'OWNER_ID')) = customer id].
    self assert: ((self rowFor: customer) at: (customerTable fieldNamed: 'ID')) = customer id.!

testOneToOne
    
    | person  personTable addressTable |
    person := GlorpPerson example1.
    self write: person.
    self write: person address.
    personTable := system existingTableNamed: 'PERSON'.
    addressTable := system existingTableNamed: 'GR_ADDRESS'.

    self assert: (rowMap includesRowForTable: personTable withKey: person).
    self assert: (rowMap includesRowForTable: addressTable withKey: person address).

    self assert: ((self rowFor: person address) at: (addressTable fieldNamed: 'ID')) = person address id.
    self assert: ((self rowFor: person) at: (personTable fieldNamed: 'ADDRESS_ID')) = person address id.
    self assert: rowMap numberOfEntries = 2.!

testOneToOneWithProxy
    | person  personTable addressTable proxy stub |
    person := GlorpPerson example1.
    proxy := Proxy new.
    proxy session: GlorpSession new.
    stub := GlorpQueryStub returningOneOf: GlorpAddress where: [:address | address id = 1].
    stub result: person address.
    proxy query: stub.
    person address: proxy.
    self deny: person address isInstantiated.

    self write: person.

    personTable := system existingTableNamed: 'PERSON'.
    addressTable := system existingTableNamed: 'GR_ADDRESS'.

    self assert: (rowMap includesRowForTable: personTable withKey: person).
    self deny: (rowMap includesRowForTable: addressTable withKey: person address).

    self deny: ((self rowFor: person) hasValueFor: (personTable fieldNamed: 'ADDRESS_ID')).
    self assert: rowMap numberOfEntries = 1.!

testRowCreation
    | descriptor person row table  |
    descriptor := system descriptorFor: GlorpPerson.
    person := GlorpPerson example1.
    rowMap := RowMap new.
    table := system existingTableNamed: 'PERSON'.
    descriptor createRowsFor: person in: rowMap.
    self assert: (rowMap includesRowForTable: table withKey: person).
    row := rowMap rowForTable: table withKey: person.
    self assert: (row at: (table fieldNamed: 'ID')) = person id.
    self assert: (row at: (table fieldNamed: 'NAME')) = person name.
    self assert: rowMap numberOfEntries = 2.! !

!GlorpMappingTest methodsFor: 'support'!

rowFor: anObject
    | descriptor |
    descriptor := system descriptorFor: anObject.
    descriptor isNil ifTrue: [^nil].

    ^rowMap rowForTable: descriptor table withKey: anObject.!

setUp
    super setUp.
    rowMap := RowMap new.!

write: anObject
    | descriptor |
    descriptor := system descriptorFor: anObject. 
    descriptor isNil ifTrue: [^self].
    descriptor createRowsFor: anObject in: rowMap.! !

!GlorpMappingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDescriptorTest methodsFor: 'tests'!

testAllClassesAndNames
    | identity1 identity2 identity3 |
    system flushAllClasses.
    identity1 := system allClasses.
    identity2 := system allClasses.
    system flushAllClasses.
    identity3 := system allClasses.
    self assert: identity1 == identity2.
    self assert: identity1 ~~ identity3.
    self should: [system allClassNames] raise: Error!

testAllMappingsForField
    | descriptor mappings |
    descriptor := system descriptorFor: GlorpCustomer.
    mappings := descriptor 
    			allMappingsForField: ((system tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID').
    self assert: mappings first attributeName = #id!

testBuildBankTransactionAndDependentsFromRow
    | transactionDescriptor object row moneyDescriptor money1 table translations session builder |
    session := GlorpMockSession new.
    session system: system.
    transactionDescriptor := system descriptorFor: GlorpBankTransaction.
    object := GlorpBankTransaction new.
    row := #(99 nil 'CDN' 98 'service charge' 'USD' 97).
    builder := ObjectBuilder new.
    builder row: row.
    transactionDescriptor populateObject: object inBuilder: builder.
    self assert: object id = 99.
    moneyDescriptor := system descriptorFor: GlorpMoney.
    money1 := GlorpMoney new.
    table := system tableNamed: 'MONEY_IMAGINARY_TABLE'.
    translations := IdentityDictionary new.
    translations at: (table fieldNamed: 'CURRENCY') put: 3.
    translations at: (table fieldNamed: 'AMOUNT') put: 4.
    builder := ElementBuilder new fieldTranslations: translations; row: row.
    moneyDescriptor
    	populateObject: money1
    	inBuilder: builder.
    self assert: money1 amount = 98.
    self assert: money1 currency = #CDN.!

testBuildPersonFromRow
    | descriptor object address session builder |
    session := GlorpMockSession new.
    session system: system.
    address := GlorpAddress new.
    session cacheAt: 127 put: address.
    descriptor := system descriptorFor: GlorpPerson.
    system tableNamed: 'PERSON'.
    object := GlorpPerson new.
    builder := ObjectBuilder new.
    builder row: #(456 'Ralph' 127).
    descriptor populateObject: object inBuilder: builder.
    self assert: object class = GlorpPerson.
    self assert: object id = 456.
    self assert: object name = 'Ralph'.
    self assert: object address getValue == address.!

testClassLookup
    self assert: (Dialect smalltalkAt: 'Object') == Object!

testDescriptorIdentity
    | descriptor |
    descriptor := system descriptorFor: GlorpCustomer.
    self assert: descriptor == (system descriptorFor: GlorpCustomer).!

testDescriptorWithNamespace
    | descriptor testCaseClass |
    Dialect isVisualWorks ifFalse: [^self].
    system := GlorpDescriptorSystemWithNamespaces new.
    testCaseClass := 'GlorpTestNamespace.GlorpTestClassInNamespace' asQualifiedReference value.
    descriptor := system descriptorFor: testCaseClass.
    self assert: descriptor describedClass == testCaseClass.!

testMappedFields
    | descriptor |
    descriptor := system descriptorFor: GlorpBankTransaction.
    self assert: (descriptor mappedFields) = (descriptor table fields).!

testMappingForField
    | descriptor mapping |
    descriptor := system descriptorFor: GlorpCustomer.
    mapping := descriptor 
    			directMappingForField: ((system tableNamed: 'GR_CUSTOMER') fieldNamed: 'ID').
    self assert: mapping attributeName = #id!

testPrimaryKeyExpressionFor
    | descriptor trans exp |
    descriptor := system descriptorFor: GlorpBankTransaction.
    trans := GlorpBankTransaction new.
    trans id: 42.
    exp := descriptor primaryKeyExpressionFor: trans.
    self assert: exp relation = #=.
    self assert: exp rightChild value = 42.!

testPrimaryKeyExpressionForFailing
    | descriptor trans |
    descriptor := system descriptorFor: GlorpBankTransaction.
    trans := GlorpCustomer new.
    self should: [descriptor primaryKeyExpressionFor: trans] raise: self errorSignal.!

testPrimaryKeyExpressionForWithCompositeKey
    self unfinished.! !

!GlorpDescriptorTest methodsFor: 'support'!

errorSignal
    Dialect isVisualAge ifTrue: [^(Smalltalk at: #SystemExceptions) at: 'ExAll'].
    ^Error.! !

!GlorpDescriptorTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpHorizontalInheritanceTest methodsFor: 'tests'!

testClassSelection
    | classes |
    classes := (session system descriptorFor: GlorpInventoryItem) classesRequiringIndependentQueries collect: [:each | each name ].
    self assert: classes size = 3.
    #(#GlorpNonperishableItem #GlorpPerishableItem #GlorpUnassembledItem) do: [:name |
    	self assert: (classes includes: name) ].

    classes := (session system descriptorFor: GlorpPerishableItem) classesRequiringIndependentQueries collect: [:each | each name ].
    self assert: classes size = 1.
    #(#GlorpPerishableItem) do: [:name |
    	self assert: (classes includes: name) ].

    classes := (session system descriptorFor: GlorpNonperishableItem) classesRequiringIndependentQueries collect: [:each | each name ].
    self assert: classes size = 2.
    #(#GlorpNonperishableItem #GlorpUnassembledItem) do: [:name |
    	self assert: (classes includes: name)].!

testDirectQuery
    | items query |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    session initializeCache.
    query := Query readManyOf: GlorpInventoryItem
    			where: [:each | each name = 'TV'].
    items := session execute: query.
    self assert: items size = 1.
    self assert: (items select: [:emp | emp isMemberOf: GlorpNonperishableItem]) size = 1.

    session initializeCache.
    items := session readManyOf: GlorpInventoryItem
    			where: [:each | each name = 'Bicycle'].
    self assert: items size = 1.
    self assert: (items select: [:emp | emp isMemberOf: GlorpUnassembledItem]) size = 1.

    session initializeCache.
    items := session readManyOf: GlorpPerishableItem
    			where: [:each | each name = 'Bicycle'].
    self assert: items size = 0.
    ] 
    		ensure: [session rollbackTransaction]!

testOrderBy
    "We can't use database-level ordering in horizontal inheritance because it does multiple queries. We could, I suppose, sort after the fact, but we don't right now"

    | items query errored |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    query := Query returningManyOf: GlorpInventoryItem
    			where: [:each | each id <= 4].
    query orderBy: #name.
    errored := false.
    self should: [items := session execute: query] raise: Error.
    ] 
    		ensure: [session rollbackTransaction]! !

!GlorpHorizontalInheritanceTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    session system: (GlorpInheritanceDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database).!

tearDown
    super tearDown.
    session reset.!

writeTestHarness
    session register: (GlorpPerishableItem new id: 1; name: 'squash'; age: 10; yourself).
    session register: (GlorpPerishableItem new id: 2; name: 'zucchini'; age: 14; yourself).
    session register: (GlorpPerishableItem new id: 3; name: 'apples'; age: 4; yourself).
    session register: (GlorpNonperishableItem new id: 4; name: 'TV'; serialNumber: 56893; yourself).
    session register: (GlorpNonperishableItem new id: 5; name: 'Fridge'; serialNumber: 12345; yourself).
    session register: (GlorpUnassembledItem new id: 6; name: 'Bicycle'; serialNumber: 83754; assemblyCost: 100; yourself).
    session register: (GlorpUnassembledItem new id: 7; name: 'Wagon'; serialNumber: 99958; assemblyCost: 20; yourself).! !

!GlorpHorizontalInheritanceTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpHorizontalInheritanceTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource.! !

!GlorpProxyTest methodsFor: 'tests'!

testCreation
    | otherProxy |
    self deny: proxy isInstantiated.
    otherProxy := Proxy new.
    self deny: otherProxy isInstantiated.!

testInstantiationFromStub
    self assert: (proxy getValue notNil).
    self assert: proxy getValue = 42.
    self assert: proxy isInstantiated.!

testPrintingInstantiated
    proxy getValue.
    self assert: proxy printString = ('{', proxy getValue printString, '}').!

testPrintingUninstantiated
    self assert: proxy printString = '{uninstantiated Glorp.GlorpAddress}'.!

testPrintingUninstantiatedCollection
    proxy query readsOneObject: false.
    self assert: proxy printString = '{uninstantiated collection of Glorp.GlorpAddress}'.! !

!GlorpProxyTest methodsFor: 'support'!

setUp
    | stub |
    super setUp.
    session := GlorpSessionResource current newSession.
    proxy := Proxy new.
    proxy session: session.
    stub := GlorpQueryStub returningOneOf: GlorpAddress where: [:address | address id = 1].
    stub result: 42.
    proxy query: stub.
    proxy parameters: #().! !

!GlorpProxyTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpProxyTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseBasicTest methodsFor: 'support'!

databaseLoginResource
    ^GlorpDatabaseLoginResource current.!

setUp
    super setUp.
    system := GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database.! !

!GlorpDatabaseBasicTest methodsFor: 'tests'!

testBeginTransactionWithCommit
    self assert: self accessor isInTransaction not.
    self accessor beginTransaction.
    self assert: self accessor isInTransaction.
    self accessor commitTransaction.
    self assert: self accessor isInTransaction not!

testBeginTransactionWithRollback
    self assert: self accessor isInTransaction not.
    self accessor beginTransaction.
    self assert: self accessor isInTransaction.
    self accessor rollbackTransaction.
    self assert: self accessor isInTransaction not!

testCreateTable
    | selectResult |
    [[self accessor beginTransaction.
    self accessor
    	dropTableNamed: 'GLORP_TEST_CREATE'
    	ifAbsent: [:ex | ex return: nil].
    self accessor
    	executeSQLString: 'CREATE TABLE GLORP_TEST_CREATE (ID varchar(4))'] 
    	ensure: [self accessor commitTransaction].
    selectResult := self accessor
    	executeSQLString: 'SELECT * FROM GLORP_TEST_CREATE'.
    self assert: selectResult isEmpty]
    	ensure:
    		[[self accessor
    			beginTransaction;
    			dropTableNamed: 'GLORP_TEST_CREATE'
    				ifAbsent: [:ex | self assert: false]]
    			ensure: [self accessor commitTransaction]].!

testDropMissingTable
    | absentFlag |
    absentFlag := false.
    [self accessor beginTransaction.
    self accessor 
    	dropTableNamed: 'GLORP_TEST_DROP' 
    	ifAbsent: [:ex  | absentFlag := true. ex sunitExitWith: nil]]
    ensure: [self accessor rollbackTransaction].
    self assert: absentFlag!

testReadEmpty
    | results |
    results := self accessor
    			executeSQLString: 'SELECT * FROM PERSON'.
    self assert: results size = 0!

testReadStatement
    | results |
    results := self accessor
    			executeSQLString: 'SELECT * FROM STUFF ORDER BY ID'.
    self assert: results size = 5.
    self assert: results first size = 2.
    self assert: results first last =  'abc'!

testRollbackRemovesData
    "Just to make sure I'm not losing my mind"
    | numAddresses |
    numAddresses := (self accessor executeSQLString: 'SELECT * FROM GR_ADDRESS') size.
    self accessor beginTransaction.
    self accessor executeSQLString: 'INSERT INTO GR_ADDRESS (ID,STREET,HOUSE_NUM)  VALUES (111,''Main Street'',''77777'')'.
    self accessor rollbackTransaction.
    self assert: numAddresses = (self accessor executeSQLString: 'SELECT * FROM GR_ADDRESS') size.! !

!GlorpDatabaseBasicTest methodsFor: 'accessing'!

accessor
    ^self databaseLoginResource accessor! !

!GlorpDatabaseBasicTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource.! !

!GlorpDatabaseBasicTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpInsertUpdateTest methodsFor: 'support'!

rowFor: anObject
    | rowMap rows |
    rowMap := RowMap new.
    session createRowsFor: anObject in: rowMap.
    rows := rowMap rowsForKey: anObject.
    self assert: rows size = 1.
    ^rows first.!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.! !

!GlorpInsertUpdateTest methodsFor: 'tests'!

testFunctionalInsertUpdateForInsert
    | testObject |
    [session beginTransaction.
    session beginUnitOfWork.
    testObject := GlorpCustomer example1.
    testObject id: 876.
    session register: testObject.
    session commitUnitOfWork.
    self assert: (testObject seenPreWrite = true).
    self assert: (testObject seenPostWrite = true).

    session beginUnitOfWork.
    session register: testObject.
    testObject name: 'Change of name'.
    session commitUnitOfWork]
    	ensure: [session rollbackTransaction]!

testRowOwnership
    | aCustomer rowMap |
    aCustomer := GlorpCustomer new.
    rowMap := RowMap new.
    (session descriptorFor: GlorpCustomer) createRowsFor: aCustomer in: rowMap.
    rowMap rowsDo: [:each | 
    	self assert: each owner = aCustomer].!

testShouldInsertForInsert
    | testObject row |
    testObject := GlorpCustomer example1.
    testObject id: 876.
    row :=self rowFor: testObject.
    self assert: (session shouldInsert: row).!

testShouldInsertForUpdate
    | testObject row |
    session beginUnitOfWork.
    testObject := GlorpCustomer example1.
    testObject id: 876.
    session cacheAt: 876 put: testObject.
    row :=self rowFor: testObject.
    self deny: (session shouldInsert: row).! !

!GlorpInsertUpdateTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpInsertUpdateTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpAirlineMeal class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExampleSystem methodsFor: 'initialize'!

initialize
    objects := Dictionary new.! !

!GlorpExampleSystem methodsFor: 'misc'!

lookupObject: aNumber ofClass: aClass ifAbsentPut: absentBlock
    ^(objects at: aClass ifAbsentPut: [Dictionary new]) at: aNumber ifAbsentPut: absentBlock.! !

!GlorpExampleSystem methodsFor: 'api'!

objectNumber: aNumber ofClass: aClass
    | symbol instance|
    instance := self lookupObject: aNumber ofClass: aClass ifAbsentPut: [aClass new].
    symbol := ('example', aClass name, 'Number', aNumber printString, ':') asSymbol.
    self perform: symbol with: instance.
    ^instance.! !

!GlorpExampleSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpBankExampleSystem methodsFor: 'examples'!

exampleGlorpAddressNumber1: anAddress
    anAddress id: 12.
    anAddress street: 'Paseo Montril'.
    anAddress number: '10185'.!

exampleGlorpBankAccountNumber1: anAccount
    anAccount id: 1.
    anAccount accountNumber: (self objectNumber: 1 ofClass: GlorpBankAccountNumber).!

exampleGlorpBankAccountNumber2: anAccount
    anAccount id: 2.
    anAccount accountNumber: (self objectNumber: 2 ofClass: GlorpBankAccountNumber).!

exampleGlorpBankAccountNumberNumber1: aBankAccountNumber
    aBankAccountNumber bankCode: '004'.
    aBankAccountNumber branchNumber: 0342.
    aBankAccountNumber accountNumber: '12345'.!

exampleGlorpBankAccountNumberNumber2: aBankAccountNumber
    aBankAccountNumber bankCode: '004'.
    aBankAccountNumber branchNumber: 0342.
    aBankAccountNumber accountNumber: '01010'.!

exampleGlorpBankTransactionNumber1: aTrans
    "Nothing to initialize"!

exampleGlorpBankTransactionNumber2: aTrans
    "Nothing to initialize"!

exampleGlorpCustomerNumber1: aCustomer
    aCustomer id: 1.
    aCustomer name: 'Fred Flintstone'.
    aCustomer addTransaction: (self objectNumber: 1 ofClass: GlorpBankTransaction).
    aCustomer addTransaction: (self objectNumber: 2 ofClass: GlorpBankTransaction).
    aCustomer addAccount: (self objectNumber: 1 ofClass: GlorpBankAccount).
    aCustomer addAccount: (self objectNumber: 2 ofClass: GlorpBankAccount).!

exampleGlorpEmailAddressNumber1: anEmailAddress 
    anEmailAddress id: 2.
    anEmailAddress user: 'foo'.
    anEmailAddress host: 'bar.com'!

exampleGlorpPersonNumber1: aPerson 
    aPerson id: 1.
    aPerson name: 'Barney Rubble'.
    aPerson address: (self objectNumber: 1 ofClass: GlorpAddress).	
    aPerson emailAddress: (self objectNumber: 1 ofClass: GlorpEmailAddress).! !

!GlorpBankExampleSystem methodsFor: 'misc'!

allClassesNames
    ^#(#GlorpCustomer #Account #GlorpBankTransaction).! !

!GlorpBankExampleSystem class methodsFor: 'instance creation'!

new
    ^super new initialize! !

!GlorpBankExampleSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpWorkingStiff methodsFor: 'accessing'!

id
    ^id!

id: anObject
    id := anObject!

name
    ^name!

name: anObject
    name := anObject! !

!GlorpWorkingStiff methodsFor: 'comparing'!

= aWorkingStiff
    ^self class = aWorkingStiff class and: [id = aWorkingStiff id and: [name = aWorkingStiff name]].! !

!GlorpWorkingStiff class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpEmployee class methodsFor: 'glorp setup'!

glorpTypeResolver
    ^FilteredTypeResolver forRootClass: GlorpEmployee! !

!GlorpEmployee class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpLineWorker methodsFor: 'accessing'!

productionLine
    ^productionLine!

productionLine: anObject
    productionLine := anObject! !

!GlorpLineWorker methodsFor: 'comparing'!

= aLineWorker
    ^super = aLineWorker and: [productionLine = aLineWorker productionLine].! !

!GlorpLineWorker class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpManager methodsFor: 'accessing'!

branch
    ^branch!

branch: anObject
    branch := anObject! !

!GlorpManager methodsFor: 'comparing'!

= aManager
    ^super = aManager and: [branch = aManager branch].! !

!GlorpManager class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpRegionalManager methodsFor: 'accessing'!

region
    ^region!

region: anObject
    region := anObject! !

!GlorpRegionalManager methodsFor: 'comparing'!

= aRegionalManager
    ^super = aRegionalManager and: [region = aRegionalManager region].! !

!GlorpRegionalManager class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpCacheTest methodsFor: 'support'!

setUp
    super setUp.
    system cachePolicy: CachePolicy new.
    session := GlorpSessionResource current newSession.
    session system: system.
    cache := session privateGetCache.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpCacheTest methodsFor: 'tests'!

testDuplicates 
    | c1 c2 |
    c1 := GlorpCustomer example1.
    c2 := GlorpCustomer example1.
    cache at: 3 insert: c1.
    cache at: 3 insert: c2.
    self assert: (cache lookupClass: GlorpCustomer key: 3) = c1.!

testDuplicatesDifferentClasses
    | cust trans |
    cust := GlorpCustomer example1.
    trans := GlorpBankTransaction example1.
    cache at: 3 insert: cust.
    cache at: 3 insert: trans.
    self assert: (cache lookupClass: GlorpCustomer key: 3) = cust.
    self assert: (cache lookupClass: GlorpBankTransaction key: 3) = trans.!

testInsert
    | customer |
    customer := GlorpCustomer example1.
    cache at: 3 insert: customer.
    self assert: (cache lookupClass: GlorpCustomer key: 3) == customer!

testRemove
    | customer |
    customer := GlorpCustomer example1.
    cache at: 3 insert: customer.
    self assert: (cache lookupClass: GlorpCustomer key: 3) == customer.
    cache removeClass: GlorpCustomer key: 3 ifAbsent: [ self signalFailure: 'Item was not in cache.' ].
    self assert: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: []) == nil.! !

!GlorpCacheTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTimedExpiryCacheTest methodsFor: 'tests'!

testExpiryReturningNilWithRealDelay
    "test that objects expire with a non-zero delay time."
    | customer customer2 |
    customer := GlorpCustomer example1.
    cache at: 3 insert: customer.
    self deny: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == nil.
    (Delay forSeconds: 2) wait.
    self assert: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == nil.
    customer2 := GlorpCustomer new.
    cache at: 3 insert: customer2.
    self assert: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == customer2.!

testNotExpiredAfterRefresh
    | customer |
    self setUpForRefresh.
    session accessor beginTransaction.
    [session accessor executeSQLString: 'INSERT INTO GR_CUSTOMER VALUES (3,''Fred Flintstone'')'.
    customer := session execute: (Query returningOneOf: GlorpCustomer where: [:each | each id = 3]).
    (Delay forSeconds: 2) wait.
    self assert: (cache hasExpired: customer).
    self assert: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == customer.
    self deny: (cache hasExpired: customer)]
    	ensure: [session accessor rollbackTransaction].!

testNotify
    | customer |
    self setUpExpiryWithZeroDelay.
    self setUpForNotify.
    customer := GlorpCustomer example1.
    cache at: 3 insert: customer.
    self deny: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == nil.
    self assert: customer seenExpiry.!

testNotifyAndRemove
    | customer |
    self setUpExpiryWithZeroDelay.
    self setUpForNotifyAndRemove.
    customer := GlorpCustomer example1.
    cache at: 3 insert: customer.
    self assert: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == nil.
    self assert: customer seenExpiry = true.!

testRegisteredObjectsDoNotExpire
    | customer |
    self setUpExpiryWithZeroDelay.
    self setUpForNotifyAndRemove.
    customer := GlorpCustomer example1.
    customer id: 3.
    cache at: 3 insert: customer.
    session beginUnitOfWork.
    session register: customer.
    self assert: (cache lookupClass: GlorpCustomer key: 3 ifAbsent: [nil]) == customer.
    self deny: customer seenExpiry.! !

!GlorpTimedExpiryCacheTest methodsFor: 'support'!

setUp
    super setUp.
    self setUpExpiryWithRealDelay.!

setUpExpiryWithRealDelay
    (cache session descriptorFor: GlorpCustomer) cachePolicy: (TimedExpiryCachePolicy new timeout: 1).
    (cache session descriptorFor: GlorpBankTransaction) cachePolicy: (TimedExpiryCachePolicy new timeout: 1).!

setUpExpiryWithZeroDelay
    (cache session descriptorFor: GlorpCustomer) cachePolicy: (TimedExpiryCachePolicy new timeout: 0).
    (cache session descriptorFor: GlorpBankTransaction) cachePolicy: (TimedExpiryCachePolicy new timeout: 0).!

setUpForExpiryActionOf: aSymbol
    (cache session descriptorFor: GlorpCustomer) cachePolicy expiryAction: aSymbol.
    (cache session descriptorFor: GlorpBankTransaction) cachePolicy expiryAction: aSymbol.!

setUpForNotify
    self setUpForExpiryActionOf: #notify.!

setUpForNotifyAndRemove
    self setUpForExpiryActionOf: #notifyAndRemove.!

setUpForRefresh
    self setUpForExpiryActionOf: #refresh.! !

!GlorpTimedExpiryCacheTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpFilteredInheritanceTest methodsFor: 'tests'!

compareEmployees: employees
    employees do: [:each |
    	| corresponding |
    	corresponding := allEmployees detect: [:eachOriginal | each id = eachOriginal id].
    	self assert: corresponding = each].!

testCacheLookup
    "Ask for an Employee which should be from the cache and which should return a Manager."

    | manager employee |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    session initializeCache.
    manager := session readOneOf: GlorpManager
    			where: [:each | each id = 3 ].
    self assert: (session cacheLookupForClass: GlorpEmployee key: 3) == manager.
    employee := session readOneOf: GlorpEmployee
    			where: [:each | each id = 3 ].
    self assert: employee == manager.

    manager := session readOneOf: GlorpRegionalManager
    			where: [:each | each id = 12 ].
    employee := session readOneOf: GlorpEmployee
    			where: [:each | each id = 12 ].
    self assert: employee == manager.

    employee := session readOneOf: GlorpManager
    			where: [:each | each id = 11 ].
    manager := session readOneOf: GlorpEmployee
    			where: [:each | each id = 11 ].
    self assert: employee == manager.

    "Test that the cache refuses to return an object which is not of the proper class or subclass."
    employee := session readOneOf: GlorpEmployee
    			where: [:each | each id = 4 ].
    self assert: (session privateGetCache lookupClass: GlorpRegionalManager key: 4 ifAbsent: []) isNil.
    manager := session readOneOf: GlorpRegionalManager
    			where: [:each | each id = 4 ].
    self assert: manager isNil.

    "Proxys seem to try a cache lookup before they execute their query...can we write a test which fails due to this?"] 
    		ensure: [session rollbackTransaction]!

testDirectQuery
    "Ask for all Employees, see if we get subclasses too"

    | employees offices |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    session initializeCache.
    employees := true 
    			ifTrue: [session readManyOf: GlorpEmployee where: [:each | each name = 'Bob']]
    			ifFalse: [session halt readManyOf: GlorpEmployee].
    self assert: employees size = 8.
    self 
    	assert: (employees select: [:emp | emp isMemberOf: GlorpEmployee]) size = 1.
    self assert: (employees select: [:emp | emp isMemberOf: GlorpManager]) size = 2.
    self 
    	assert: (employees select: [:emp | emp isMemberOf: GlorpLineWorker]) size = 4.
    self 
    	assert: (employees select: [:emp | emp isMemberOf: GlorpRegionalManager]) size 
    			= 1.
    self compareEmployees: employees.
    session initializeCache.
    offices := session readOneOf: GlorpOffice
    			where: [:each | each employeeOfMonth name = 'Bob'].	"There is no regional manager with id = 4 but we can ensure that the type info is getting into the query's key by asking for one and seeing that it doesn't exist"
    session initializeCache.
    self 
    	assert: (session readOneOf: GlorpRegionalManager where: [:each | each id = 4]) 
    			== nil] 
    		ensure: [session rollbackTransaction]!

testDirectQuery2
    "Ask for all Employees, see if we get subclasses too"

    | employees |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    session initializeCache.
    employees := session readManyOf: GlorpEmployee.
    self assert: employees size = 12.
    self 
    	assert: (employees select: [:emp | emp isMemberOf: GlorpEmployee]) size = 2.
    self assert: (employees select: [:emp | emp isMemberOf: GlorpManager]) size = 3.
    self 
    	assert: (employees select: [:emp | emp isMemberOf: GlorpLineWorker]) size = 5.
    self 
    	assert: (employees select: [:emp | emp isMemberOf: GlorpRegionalManager]) size 
    			= 2.
] 
    		ensure: [session rollbackTransaction]!

testOrderBy
    | employees query |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    query := Query returningManyOf: GlorpEmployee
    			where: [:each | each id <= 4].
    query orderBy: #name.
    query orderBy: #id.
    employees := session execute: query.
    self assert: (employees asSortedCollection: [:a :b | a name = b name ifTrue: [
    	a id <= b id] ifFalse: [a name < b name]]) asArray = employees]
    		ensure: [session rollbackTransaction]!

testRelationshipQuery
    "Ask for all Employees in a given office and test that the return types are correct."

    | employees office |
    session beginTransaction.
    
    [session beginUnitOfWork.
    self writeTestHarness.
    session commitUnitOfWork.
    session initializeCache.
    office := session readOneOf: GlorpOffice
    			where: [:each | each id = 1 ].
    employees := office employees.
    self assert: employees size = 6.
    self assert: (employees select: [:emp | emp isMemberOf: GlorpEmployee]) size = 2.
    self assert: (employees select: [:emp | emp isMemberOf: GlorpManager]) size = 1.
    self assert: (employees select: [:emp | emp isMemberOf: GlorpLineWorker]) size = 2.
    self assert: (employees select: [:emp | emp isMemberOf: GlorpRegionalManager]) size = 1] 
    		ensure: [session rollbackTransaction]! !

!GlorpFilteredInheritanceTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    session system: (GlorpInheritanceDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database).!

tearDown
    super tearDown.
    session reset.
    session := nil.!

writeTestHarness
    | office1 office2  eom1 eom2 jim bob |
    session register: (office1 := GlorpOffice new id: 1; yourself).
    session register: (office2 := GlorpOffice new id: 2; yourself).
    office1 addEmployee: (eom1 := GlorpEmployee new id: 1; name: 'Bob'; yourself).
    office1 addEmployee: (GlorpEmployee new id: 2; name: 'Jim'; yourself).
    office1 addEmployee: (GlorpManager new id: 3; name: 'Bob'; branch: 'West'; yourself).
    office2 addEmployee: (eom2 := GlorpManager new id: 4; name: 'Steve'; branch: 'East'; yourself).
    office2 addEmployee: (GlorpManager new id: 5; name: 'Bob'; branch: 'South'; yourself).
    office1 addEmployee: (GlorpLineWorker new id: 6; name: 'Wally'; productionLine: 'Gold'; yourself).
    office1 addEmployee: (GlorpLineWorker new id: 7; name: 'Bob'; productionLine: 'Silver'; yourself).
    office2 addEmployee: (GlorpLineWorker new id: 8; name: 'Bob'; productionLine: 'Tin'; yourself).
    office2 addEmployee: (GlorpLineWorker new id: 9; name: 'Bob'; productionLine: 'Copper'; yourself).
    office2 addEmployee: (GlorpLineWorker new id: 10; name: 'Bob'; productionLine: 'Steel'; yourself).
    office1 addEmployee: (GlorpRegionalManager new id: 11; name: 'Bob'; branch: 'South'; region: 'MidWest'; yourself).
    office2 addEmployee: (GlorpRegionalManager new id: 12; name: 'Mike'; branch: 'North'; region: 'NorthEast'; yourself).
    office1 employeeOfMonth: eom1.
    office2 employeeOfMonth: eom2.

    session register: (jim := GlorpWorkingStiff new id: 13; name: 'Jim'; yourself).
    session register: (bob := GlorpWorkingStiff new id: 14; name: 'Bob'; yourself).

    allEmployees := (Array with: jim with: bob), office1 employees, office2 employees.! !

!GlorpFilteredInheritanceTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpFilteredInheritanceTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource.! !

!GlorpSQLPrintingTest methodsFor: 'tests'!

testDatePrinting
    | date stream |
    date := Dialect newDateWithYears: 1997 months: 11 days: 14.
    stream := WriteStream on: String new.
    date glorpPrintSQLOn: stream.
    self assert: stream contents = '''1997-11-14'''.

    date := Dialect newDateWithYears: 2002 months: 5 days: 2.
    stream := WriteStream on: String new.
    date glorpPrintSQLOn: stream.
    self assert: stream contents = '''2002-05-02'''.! !

!GlorpSQLPrintingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDescriptorSystemWithNamespaces methodsFor: 'accessing'!

allTableNames
    ^#()!

constructAllClasses
    ^(super constructAllClasses)
    	add: GlorpTestClassInNamespace;
    	yourself!

descriptorForGlorpTestClassInNamespace: aDescriptor 
    ^aDescriptor! !

!GlorpDescriptorSystemWithNamespaces class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpSessionResource methodsFor: 'setup'!

setUp
    | login |
    super setUp.
    login := GlorpDatabaseLoginResource current.
    GlorpDemoTablePopulatorResource current.
    session := GlorpSession new.
    session system: (GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database).
    session accessor: login accessor.! !

!GlorpSessionResource methodsFor: 'accessing'!

newSession
    self setUp.
    ^self session.!

session
    ^session.! !

!GlorpSessionResource class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource.! !

!GlorpSessionResource class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpMessageCollectorTest methodsFor: 'support'!

setUp
    super setUp.
    collector := MessageArchiver new! !

!GlorpMessageCollectorTest methodsFor: 'tests'!

dNUException
    ^Dialect isVisualAge 
    	ifTrue: [(Smalltalk at: #SystemExceptions) at: 'ExAll']
    	ifFalse: [MessageNotUnderstood].!

testExpressionCreation
    | exp |
    exp := collector foo asGlorpExpression.
    self assert: exp name == #foo.
    self assert: exp base class == BaseExpression!

testMessageCollectorDNU
    | message caught |
    message := Message selector: #foo arguments: #().
    caught := false.
    [collector basicDoesNotUnderstand: message] on: self dNUException
    	do: [:signal | caught := true. signal sunitExitWith: nil].
    self assert: caught!

testMessageIntercept
    | foo |
    foo := collector foo.
    self assert: foo privateGlorpMessage selector == #foo.
    self assert: foo privateGlorpReceiver == collector.! !

!GlorpMessageCollectorTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpServiceCharge methodsFor: 'accessing'!

amount
    ^amount!

amount: anObject
    amount := anObject!

description
    ^description!

description: anObject
    description := anObject! !

!GlorpServiceCharge methodsFor: 'initialize'!

initialize! !

!GlorpServiceCharge class methodsFor: 'instance creation'!

default
    ^self new
    	amount: (GlorpMoney forAmount: 3);
    	description: 'additional overcharge'.!

new
    ^super new initialize.! !

!GlorpServiceCharge class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpSessionBasedTest methodsFor: 'support'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.!

tearDown
    super tearDown.
    session reset.
    session := nil.! !

!GlorpSessionBasedTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVirtualCollectionBasicTest methodsFor: 'support'!

realObjects
    "Get the real objects from a virtual collection without resorting to any of its mechanisms except do:, so we can validate against more complex things."
    ^self realObjectsFrom: vc.!

realObjectsFrom: aVirtualCollection
    "Get the real objects from a virtual collection without resorting to any of its mechanisms except do:, so we can validate against more complex things."
    | all |
    all := OrderedCollection new.
    aVirtualCollection do: [:each | all add: each].
    ^all.!

setUp
    session := GlorpSessionResource current newSession.
    session beginTransaction.
    self writePersonRows.
    vc := session virtualCollectionOf: GlorpPerson.!

tearDown
    session rollbackTransaction.!

writePersonRows
    session writeRow: session system exampleAddressRowForOrdering1.
    session writeRow: session system exampleAddressRowForOrdering2.
    session writeRow: session system exampleAddressRowForOrdering3.
    session writeRow: session system examplePersonRowForOrdering1.
    session writeRow: session system examplePersonRowForOrdering2.
    session writeRow: session system examplePersonRowForOrdering3.! !

!GlorpVirtualCollectionBasicTest methodsFor: 'tests'!

testCollect
    | ids |
    ids := vc collect: [:each | each id].
    
    self assert: ids size = 3.
    ids do: [:each | self assert: each isInteger].!

testCreation
    
    self assert: vc notNil.
    self should: [vc isKindOf: GlorpVirtualCollection].!

testDo
    | all |
    all := OrderedCollection new.
    vc do: [:each |
    	self assert: (each isKindOf: GlorpPerson).
    	all add: each.
    	].
    self assert: all size = 3.
    self assert: all asSet size = 3.
    self assert: (all collect: [:each | each id]) asSortedCollection asArray = #(86 87 88).!

testInject
    | sumofIds |
    sumofIds := vc inject: 0 into: [:sum :each | sum + each id].
    self assert: sumofIds = (86 + 87 + 88).!

testIsEmpty
    | vc2 |
    self deny: vc isEmpty.
    vc2 := vc select: [:each | each id = 98].
    self assert: vc2 isEmpty.!

testReject
    | vc2 |
    vc2 := vc reject: [:each | each id > 87 ].
    self deny: vc isInstantiated.
    self deny: vc2 isInstantiated.
    self assert: vc2 size = 2.
    self deny: vc isInstantiated.
    self assert: vc size = 3.
    self assert: (self realObjectsFrom: vc2) size = 2.!

testSelect
    | vc2 |
    vc2 := vc select: [:each | each id <= 87 ].
    self deny: vc isInstantiated.
    self deny: vc2 isInstantiated.
    self assert: vc2 size = 2.
    self deny: vc isInstantiated.
    self assert: vc size = 3.
    self assert: (self realObjectsFrom: vc2) size = 2.! !

!GlorpWeakCacheTest methodsFor: 'support'!

checkCacheExhaustivelyFor: aBlock
    "Check to make sure the cache satisfies the criteria. Since this relies on unpredictable finalization, do a full 10 garbage collect then wait iterations. Don't return early, because we're checking to see that finalization *doesn't* happen"
    self assert: (self doesCacheExhaustivelySatisfy: aBlock).!

checkCacheFor: aBlock
    "Check to make sure the cache satisfies the criteria. Since this relies on unpredictable finalization, do up to 10 garbage collect then wait iterations. If it's true before that, return early, but if it's not true at the end, fail"
    self assert: (self doesCacheSatisfy: aBlock).!

doesCacheExhaustivelySatisfy: aBlock
    | result |
    result := false.
    10
    	timesRepeat:
    		[Dialect garbageCollect.
    		(Delay forMilliseconds: 100) wait.
    		result := aBlock value].
    ^result.!

doesCacheSatisfy: aBlock
    10
    	timesRepeat:
    		[Dialect garbageCollect.
    		(Delay forMilliseconds: 100) wait.
    		aBlock value ifTrue: [^true]].
    ^false.!

mournKeyOf: anEphemeron
    mourned := true.!

setUp
    super setUp.
    system cachePolicy: WeakVWCachePolicy new.
    mourned := false.! !

!GlorpWeakCacheTest methodsFor: 'tests'!

testEphemeralValue
    | value ephemeron |
    Dialect isVisualWorks ifFalse: [ ^self ].
    value := Object new.
    ephemeron := (Dialect smalltalkAt: #EphemeralValue) key: 'abc' value: value.
    ephemeron manager: self.
    Dialect garbageCollect.
    value := nil.
    self should: [10 timesRepeat: [
    	mourned ifFalse: [Dialect garbageCollect.
    	(Delay forMilliseconds: 100) wait]].
    	mourned].!

testEphemeralValueDictionary
    | value dict done |
    Dialect isVisualWorks ifFalse: [ ^self ].
    value := Object new.
    dict := WeakVWCachePolicy new dictionaryClass new.
    dict at: 'abc' put: value.
    Dialect garbageCollect.
    value := nil.
    done := false.
    self should:
    	[10	timesRepeat:
    		[done ifFalse: [
    			Dialect garbageCollect.
    			(Delay forMilliseconds: 100) wait.
    			dict do: [ :each | ].
    			done := dict size = 0]].
    		 done].!

testEphemeron
    | value ephemeron |
    Dialect isVisualWorks ifFalse: [ ^self ].
    value := Object new.
    ephemeron := (Dialect smalltalkAt: #Ephemeron) key: value value: 'abc'.
    ephemeron manager: self.
    Dialect garbageCollect.
    value := nil.
    self should: [10 timesRepeat: [
    	mourned ifFalse: [Dialect garbageCollect.
    	(Delay forMilliseconds: 100) wait]].
    	mourned].!

testEphemeronDictionary
    | value dict done |
    Dialect isVisualWorks ifFalse: [ ^self ].
    value := Object new.
    dict := (Dialect smalltalkAt: #EphemeronDictionary) new.
    dict at: value put: 'abc'.
    Dialect garbageCollect.
    value := nil.
    done := false.
    self should:
    	[10	timesRepeat:
    		[done ifFalse: [
    			Dialect garbageCollect.
    			(Delay forMilliseconds: 100) wait.
    			done := dict size = 0]].
    		 done].!

testUnreferencedExcessObjectsAreRemoved
    Dialect isVisualWorks ifFalse: [ ^self ].
    system cachePolicy numberOfElements: 1.
    cache at: 3 insert: GlorpCustomer new.
    cache at: 4 insert: GlorpCustomer new.
    self checkCacheFor: [(cache containsObjectForClass: GlorpCustomer key: 3) not].
    self assert: (cache containsObjectForClass: GlorpCustomer key: 4).!

testUnreferencedObjectsAreRemoved
    Dialect isVisualWorks ifFalse: [ ^self ].
    system cachePolicy numberOfElements: 0.
    cache at: 3 insert: GlorpCustomer new.
    self
    	checkCacheFor: [(cache containsObjectForClass: GlorpCustomer key: 3) not].!

testUnreferencedObjectsAreRemovedInTheRightOrder
    | customer |
    Dialect isVisualWorks ifFalse: [ ^self ].
    system cachePolicy numberOfElements: 1.
    cache at: 3 insert: GlorpCustomer new.
    cache at: 4 insert: GlorpCustomer new.
    customer := cache lookupClass: GlorpCustomer key: 3.
    self deny: customer isNil.
    cache at: 3 insert: customer.
    self checkCacheFor: [(cache containsObjectForClass: GlorpCustomer key: 4) not].
    self assert: (cache containsObjectForClass: GlorpCustomer key: 3).!

testUnreferencedObjectsNotRemovedDueToExtraReferences
    Dialect isVisualWorks ifFalse: [ ^self ].
    cache at: 3 insert: GlorpCustomer new.
    self checkCacheExhaustivelyFor: [(cache containsObjectForClass: GlorpCustomer key: 3)].! !

!GlorpWeakCacheTest methodsFor: 'initializing'!

initialize! !

!GlorpWeakCacheTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpWeakCacheTest class methodsFor: 'instance creation'!

new
    "Answer a newly created and initialized instance."

    ^super new initialize! !

!GlorpFloat8Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform float8!

testFloat8
    type := (self platform) double.

    self helpTestValue: nil.
    self helpTestValue: (Dialect coerceToDoublePrecisionFloat: 3.14) compareWith: [:read :original |
    	read - original <= 0.0000001].! !

!GlorpFloat8Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpNumeric5Test methodsFor: 'tests'!

testNumeric5
    self platform supportsVariableSizedNumerics ifFalse: [^self].

    self helpTestValue: nil.
    self helpTestValue: 12.	
    self helpTestValue: 10991.		
    self helpTestInvalidValue: 3.14.! !

!GlorpNumeric5Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform numeric precision: 5.! !

!GlorpNumeric5Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpQueryTableAliasingTest methodsFor: 'tests'!

testAliasWithEmbeddedMapping
    self unfinished.!

testBuildingObject
    | customer |
    elementBuilder instance: GlorpCustomer new.
    elementBuilder requiresPopulating: true.
    elementBuilder buildObjectFrom: #(12 'Name').
    customer := elementBuilder instance.
    self assert: customer class == GlorpCustomer.
    self assert: customer id = 12.
    self assert: customer name = 'Name'.!

testElementBuilderFields
    elementBuilder fieldsForSelectStatement 
    	do: [:each | self assert: each table name = 't1']!

testExpressionTableAlias
    | fields |
    fields := expression translateFields: expression descriptor mappedFields.
    fields do: [:each | self assert: each table name = 't1']!

testQueryPrintingFields
    | stream |
    query 
    	initResultClass: GlorpCustomer
    	criteria: expression
    	singleObject: true.
    query setupTracing.
    query computeFields.
    stream := String new writeStream.
    query printSelectFieldsOn: stream.
    self assert: stream contents = 't1.ID, t1.NAME'!

testQueryPrintingSimpleWhereClause
    | string |
    string := self helpTestPrintingWhereClause: ((expression get: #name) get: #= withArguments: #('Fred')).
    self assert: string = '(t1.NAME = ''Fred'')'!

testQueryPrintingTables
    | stream string |
    query 
    	initResultClass: GlorpCustomer
    	criteria: expression
    	singleObject: true.
    query setupTracing.
    query computeFields.
    stream := String new writeStream.
    query printTablesOn: stream.
    string := stream contents.
    self assert: string = '
 FROM GR_CUSTOMER t1'! !

!GlorpQueryTableAliasingTest methodsFor: 'support'!

helpTestPrintingWhereClause: anExpression
    | command |
    query 
    	initResultClass: GlorpCustomer
    	criteria: expression
    	singleObject: true.
    query setupTracing.
    query computeFields.
    command := GlorpNullCommand useBinding: false platform: system platform.
    anExpression	
    	printSQLOn: command
    	withParameters: Dictionary new.
    ^command sqlString.!

setUp
    super setUp.
    query := SimpleQuery new.
    expression := BaseExpression new.
    expression descriptor: (system descriptorFor: GlorpCustomer).
    elementBuilder := ObjectBuilder for: expression in: query.
    expression aliasTable: (system tableNamed: 'GR_CUSTOMER') to: 't1'.
    session := GlorpSession new.
    session system: system.
    query session: system session.! !

!GlorpQueryTableAliasingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpInheritanceDescriptorSystem methodsFor: 'tables'!

tableForEMPLOYEE: aTable
    aTable name: 'EMPLOYEE'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'OFFICE_ID' type: platform int4.
    aTable createFieldNamed: 'EMPLOYEE_TYPE' type: (platform varChar: 20).
    aTable createFieldNamed: 'BRANCH' type: (platform varChar: 20).
    aTable createFieldNamed: 'REGION' type: (platform varChar: 20).
    aTable createFieldNamed: 'PRODUCTION_LINE' type: (platform varChar: 20).!

tableForNONPERISHABLE_ITEM: aTable
    aTable name: 'NONPERISHABLE_ITEM'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'SERIAL_NUMBER' type: platform int4.!

tableForOFFICE: aTable
    aTable name: 'OFFICE'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'ADDRESS_ID' type: platform int4.
    aTable createFieldNamed: 'EMPLOYEE_OF_MONTH' type: platform int4.!

tableForPERISHABLE_ITEM: aTable
    aTable name: 'PERISHABLE_ITEM'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'AGE' type: platform int4.!

tableForPOULTRY: aTable
    aTable name: 'POULTRY'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'AGE' type: platform int4.
    aTable createFieldNamed: 'FEATHER_COLOR' type: (platform varChar: 20).!

tableForUNASSEMBLED_ITEM: aTable
    aTable name: 'UNASSEMBLED_ITEM'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).
    aTable createFieldNamed: 'SERIAL_NUMBER' type: platform int4.
    aTable createFieldNamed: 'ASSEM_COST' type: platform int4.!

tableForWORKING_STIFF: aTable
    aTable name: 'WORKING_STIFF'.
    (aTable createFieldNamed: 'ID' type: platform int4) bePrimaryKey.
    aTable createFieldNamed: 'NAME' type: (platform varChar: 20).! !

!GlorpInheritanceDescriptorSystem methodsFor: 'descriptors/employees'!

descriptorForGlorpEmployee: aDescriptor
    | table |
    table := self tableNamed: 'EMPLOYEE'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    (self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'E' field: (table fieldNamed: 'EMPLOYEE_TYPE').
    ^aDescriptor!

descriptorForGlorpInventoryItem: aDescriptor
    (self typeResolverFor: GlorpInventoryItem) register: aDescriptor abstract: true.
    ^aDescriptor!

descriptorForGlorpLineWorker: aDescriptor
    | table |
    table := self tableNamed: 'EMPLOYEE'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    (self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'W' field: (table fieldNamed: 'EMPLOYEE_TYPE').
    aDescriptor addMapping: (DirectMapping from: #productionLine to: (table fieldNamed: 'PRODUCTION_LINE')).
    ^aDescriptor!

descriptorForGlorpManager: aDescriptor
    | table |
    table := self tableNamed: 'EMPLOYEE'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #branch to: (table fieldNamed: 'BRANCH')).
    (self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'M' field: (table fieldNamed: 'EMPLOYEE_TYPE').
    ^aDescriptor!

descriptorForGlorpNonperishableItem: aDescriptor
    | table |
    table := self tableNamed: 'NONPERISHABLE_ITEM'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #serialNumber to: (table fieldNamed: 'SERIAL_NUMBER')).
    (self typeResolverFor: GlorpInventoryItem) register: aDescriptor.
    ^aDescriptor!

descriptorForGlorpOffice: aDescriptor
    | table |
    table := self tableNamed: 'OFFICE'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (OneToManyMapping new
    		attributeName: #employees;
    		referenceClass: GlorpEmployee;
    		mappingCriteria: (Join 
    			from: (table fieldNamed: 'ID')
    			to: ((self tableNamed: 'EMPLOYEE') fieldNamed: 'OFFICE_ID'))).
    aDescriptor addMapping: (OneToOneMapping new
    	attributeName: #employeeOfMonth;
    	referenceClass: GlorpEmployee;
    	mappingCriteria: (Join
    			from: (table fieldNamed: 'EMPLOYEE_OF_MONTH')
    			to: ((self tableNamed: 'EMPLOYEE') fieldNamed: 'ID'))).
    ^aDescriptor!

descriptorForGlorpPerishableItem: aDescriptor
    | table |
    table := self tableNamed: 'PERISHABLE_ITEM'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #age to: (table fieldNamed: 'AGE')).
    (self typeResolverFor: GlorpInventoryItem) register: aDescriptor.
    ^aDescriptor!

descriptorForGlorpPoultry: aDescriptor
    "Poultry does not participate in the InventoryItem heirarchy (ie it will not be retrieved when asking for an InventoryItem)"
    | table |
    table := self tableNamed: 'POULTRY'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #age to: (table fieldNamed: 'AGE')).
    aDescriptor addMapping: (DirectMapping from: #featherColor to: (table fieldNamed: 'FEATHER_COLOR')).
    ^aDescriptor!

descriptorForGlorpRegionalManager: aDescriptor
    | table |
    table := self tableNamed: 'EMPLOYEE'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #branch to: (table fieldNamed: 'BRANCH')).
    aDescriptor addMapping: (DirectMapping from: #region to: (table fieldNamed: 'REGION')).
    (self typeResolverFor: GlorpEmployee) register: aDescriptor keyedBy: 'R' field: (table fieldNamed: 'EMPLOYEE_TYPE').
    ^aDescriptor!

descriptorForGlorpUnassembledItem: aDescriptor
    | table |
    table := self tableNamed: 'UNASSEMBLED_ITEM'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    aDescriptor addMapping: (DirectMapping from: #serialNumber to: (table fieldNamed: 'SERIAL_NUMBER')).
    aDescriptor addMapping: (DirectMapping from: #assemblyCost to: (table fieldNamed: 'ASSEM_COST')).
    (self typeResolverFor: GlorpInventoryItem) register: aDescriptor.
    ^aDescriptor!

descriptorForGlorpWorkingStiff: aDescriptor
    "Working stiff does not participate in the Employee type mapping scheme (it uses its own table)"
    | table |
    table := self tableNamed: 'WORKING_STIFF'.
    aDescriptor table: table.
    aDescriptor addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID')).
    aDescriptor addMapping: (DirectMapping from: #name to: (table fieldNamed: 'NAME')).
    ^aDescriptor! !

!GlorpInheritanceDescriptorSystem methodsFor: 'misc'!

allTableNames
    ^#('EMPLOYEE' 'OFFICE' 'PERISHABLE_ITEM' 'NONPERISHABLE_ITEM' 'UNASSEMBLED_ITEM' 'WORKING_STIFF' 'POULTRY').!

constructAllClasses
    ^(super constructAllClasses)
    	add: GlorpOffice;
    	add: GlorpEmployee;
    	add: GlorpManager;
    	add: GlorpRegionalManager;
    	add: GlorpLineWorker;
    	add: GlorpInventoryItem;
    	add: GlorpPerishableItem;
    	add: GlorpNonperishableItem;
    	add: GlorpUnassembledItem;
    	add: GlorpWorkingStiff;
    	add: GlorpPoultry;
    	yourself! !

!GlorpInheritanceDescriptorSystem methodsFor: 'type resolvers'!

typeResolverForGlorpInventoryItem
    ^HorizontalTypeResolver forRootClass: GlorpInventoryItem.! !

!GlorpInheritanceDescriptorSystem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpAdHocMappingTest methodsFor: 'tests'!

moneyNegatingMappingTo: amountField 
    ^AdHocMapping 
    	forAttribute: #amount
    	fromDb: [:row :elementBuilder :context | (elementBuilder valueOfField: (context translateField: amountField) in: row) negated]
    	toDb: [:rows :attribute | (rows at: table) at: amountField put: attribute negated]
    	mappingFields: (Array with: amountField)!

testNegateMappingRead
    | amountField inputRow builder |
    table := system tableNamed: 'MONEY_IMAGINARY_TABLE'.
    amountField := table fieldNamed: 'AMOUNT'.
    mapping := self moneyNegatingMappingTo: amountField.
    money := GlorpMoney basicNew.
    inputRow := #('US' 1).
    builder := ElementBuilder new.
    builder row: inputRow.
    mapping mapObject: money inElementBuilder: builder.
    self assert: money amount = -1.!

testNegateMappingWrite
    | amountField outputRow |
    table := system tableNamed: 'MONEY_IMAGINARY_TABLE'.
    amountField := table fieldNamed: 'AMOUNT'.
    mapping := self moneyNegatingMappingTo: amountField.
    descriptor := Descriptor new.
    descriptor table: table.
    descriptor addMapping: mapping.
    money := GlorpMoney forAmount: 3.
    rowMap := RowMap new.
    mapping mapFromObject: money intoRowsIn: rowMap.
    outputRow := rowMap rowForTable: table withKey: money.
    self assert: (outputRow at: (table fieldNamed: 'AMOUNT')) = -3!

testSplitMappingRead
    | inputRow builder |
    money := GlorpCompressedMoney basicNew.
    mapping := (system descriptorFor: GlorpCompressedMoney)
    	mappingForAttributeNamed: #array.
    inputRow := #(432 'US' 1).
    builder := ElementBuilder new.
    builder row: inputRow.
    mapping mapObject: money inElementBuilder: builder.
    self assert: money amount = 1.
    self assert: money currency = 'US'.!

testSplitMappingWrite
    | outputRow |
    money := GlorpCompressedMoney currency: 'DM' amount: 99.
    mapping := (system descriptorFor: GlorpCompressedMoney) 
    			mappingForAttributeNamed: #array.
    rowMap := RowMap new.
    mapping mapFromObject: money intoRowsIn: rowMap.
    table := mapping descriptor primaryTable.
    outputRow := rowMap rowForTable: table withKey: money.
    self assert: (outputRow at: (table fieldNamed: 'AMOUNT')) = 99.
    self assert: (outputRow at: (table fieldNamed: 'CURRENCY_NAME')) = 'DM'! !

!GlorpAdHocMappingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpInventoryItem methodsFor: 'accessing'!

id
    ^id!

id: anObject
    id := anObject!

name
    ^name!

name: anObject
    name := anObject! !

!GlorpInventoryItem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPerishableItem methodsFor: 'accessing'!

age
    ^age!

age: anObject
    age := anObject! !

!GlorpPerishableItem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpPoultry methodsFor: 'accessing'!

featherColor
    ^featherColor!

featherColor: anObject
    featherColor := anObject! !

!GlorpPoultry class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpNonperishableItem methodsFor: 'accessing'!

serialNumber
    ^serialNumber!

serialNumber: anObject
    serialNumber := anObject! !

!GlorpNonperishableItem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpUnassembledItem methodsFor: 'accessing'!

assemblyCost
    ^assemblyCost!

assemblyCost: anObject
    assemblyCost := anObject! !

!GlorpUnassembledItem class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDatabaseAccessorTest methodsFor: 'tests'!

testLoggingSwitch
    | currentSetting |
    currentSetting := DatabaseAccessor loggingEnabled.
    DatabaseAccessor loggingEnabled: true.
    DatabaseAccessor allSubclasses do: [:ea | self assert: ea new logging].
    DatabaseAccessor loggingEnabled: false.
    DatabaseAccessor allSubclasses do: [:ea | self deny: ea new logging].
    DatabaseAccessor loggingEnabled: currentSetting.! !

!GlorpDatabaseAccessorTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpIntegerTest methodsFor: 'tests'!

testInteger
    type := (self platform) integer.
    self helpTestValue: nil.
    self helpTestValue: 3212321.! !

!GlorpIntegerTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform integer.! !

!GlorpIntegerTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTransformedTime methodsFor: 'accessing'!

id
    ^id!

id: anObject
    id := anObject!

time
    ^time!

time: anObject
    time := anObject! !

!GlorpTransformedTime methodsFor: 'initialize'!

initialize
    time := Time now.! !

!GlorpTransformedTime class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpTransformedTime class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpExpressionTableAliasingTest methodsFor: 'support'!

helpTestBasicAliasing: aTable 
    self deny: exp hasTableAliases.
    exp assignTableAliasesStartingAt: 1.
    self assert: exp hasTableAliases.
    self assert: exp tableAliases size = 1.
    self 
    	assert: (exp tableAliases at: aTable) name 
    			= 't1'! !

!GlorpExpressionTableAliasingTest methodsFor: 'tests'!

testBase
    exp := BaseExpression new.
    exp descriptor: (system descriptorFor: GlorpCustomer).
    self helpTestBasicAliasing: (system tableNamed: 'GR_CUSTOMER').!

testMapping
    | base |
    base := BaseExpression new.
    base descriptor: (system descriptorFor: GlorpCustomer).
    exp := base get: 'transactions'.
    self helpTestBasicAliasing: (system tableNamed: 'BANK_TRANS').!

testTable
    | base transTable |
    base := BaseExpression new.
    base descriptor: (system descriptorFor: GlorpCustomer).
    transTable := system tableNamed: 'BANK_TRANS'.
    exp := base getTable: transTable.
    self helpTestBasicAliasing: transTable!

testTableSameAsBase
    | base custTable |
    base := BaseExpression new.
    base descriptor: (system descriptorFor: GlorpCustomer).
    custTable := system tableNamed: 'GR_CUSTOMER'.
    exp := base getTable: custTable.
    self deny: exp hasTableAliases.
    exp assignTableAliasesStartingAt: 1.
    base assignTableAliasesStartingAt: 42.
    self deny: exp hasTableAliases.
    self assert: (exp aliasedTableFor: custTable) name = 't42'! !

!GlorpExpressionTableAliasingTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpQueryCopyingTest methodsFor: 'tests'!

testExpressionTableAliases
    query prepare.
    newQuery := query copy.
    self assert: (self tableAliasesPresentFor: query).
    self deny: (self tableAliasesPresentFor: newQuery).!

testPreparedness
    self deny: query isPrepared.
    query prepare.
    newQuery := query copy.
    self assert: query isPrepared.
    self deny: newQuery isPrepared.! !

!GlorpQueryCopyingTest methodsFor: 'As yet unclassified'!

tableAliasesPresentFor: aQuery
    aQuery criteria detect: [:each | each hasTableAliases] ifNone: [^false].
    ^true.! !

!GlorpQueryCopyingTest methodsFor: 'support'!

setUp
    super setUp.
    query := Query returningManyOf: GlorpCustomer.
    query criteria: [:each | each accounts anySatisfy: [:foo | foo id = 12]].
    session := GlorpSessionResource current newSession.
    query session: session.! !

!GlorpAddress methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPutAll: '(', id printString, ',', street printString, ',' , number printString, ')'.! !

!GlorpAddress methodsFor: 'accessing'!

id
    "Private - Answer the value of the receiver's ''id'' instance variable."

    ^id!

id: anObject
    "Private - Set the value of the receiver's ''id'' instance variable to the argument, anObject."

    id := anObject!

number
    "Private - Answer the value of the receiver's ''number'' instance variable."

    ^number!

number: anObject
    "Private - Set the value of the receiver's ''number'' instance variable to the argument, anObject."

    number := anObject!

street
    "Private - Answer the value of the receiver's ''street'' instance variable."

    ^street!

street: anObject
    "Private - Set the value of the receiver's ''street'' instance variable to the argument, anObject."

    street := anObject! !

!GlorpAddress class methodsFor: 'examples'!

example1
    ^self new
    	id: 1;
    	street: 'West 47th Ave';
    	number: '2042'.!

example1WithChangedAddress
    ^self new
    	id: 1;
    	street: 'Garden of the Gods';
    	number: '99999'.!

example2
    ^self new
    	id: 2;
    	street: 'Nowhere';
    	number: '1000'.! !

!GlorpAddress class methodsFor: 'glorp setup'!

glorpSetupDescriptor: aDescriptor forSystem: aDescriptorSystem 
    | table |
    table := aDescriptorSystem tableNamed: 'GR_ADDRESS'.
    aDescriptor table: table.
    aDescriptor
    	addMapping: (DirectMapping from: #id to: (table fieldNamed: 'ID'));
    	addMapping: (DirectMapping from: #street to: (table fieldNamed: 'STREET'));
    	addMapping: (DirectMapping from: #number to: (table fieldNamed: 'HOUSE_NUM'))! !

!GlorpAddress class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpAttributeAccessorTest methodsFor: 'tests'!

testGetSet
    | accessor obj objWithNoAccessors |
    obj := 2 asValue.
    objWithNoAccessors := (GlorpObjectWithNoAccessors new)
    							value_: 'Glorp';
    							yourself.

    accessor := AttributeAccessor newForAttributeNamed: #value.

    accessor useDirectAccess: true.
    self assert: 2 == (accessor getValueFrom: obj).
    accessor setValueIn: obj to: 3.
    self assert: 3 == (accessor getValueFrom: obj).
    self assert: 'Glorp' = (accessor getValueFrom: objWithNoAccessors).
    accessor setValueIn: objWithNoAccessors to: 'GLORP'.
    self assert: 'GLORP' = (accessor getValueFrom: objWithNoAccessors).

    accessor useDirectAccess: false.
    self assert: 3 == (accessor getValueFrom: obj).
    accessor setValueIn: obj to: 2.
    self assert: 2 == (accessor getValueFrom: obj).
    self should: [accessor getValueFrom: objWithNoAccessors] raise: Error.
    self should: [accessor setValueIn: objWithNoAccessors to: 'Glorp'] raise: Error.! !

!GlorpAttributeAccessorTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDeleteInUnitOfWorkTest methodsFor: 'tests'!

testCommit
    unitOfWork delete: GlorpAddress example1.
    unitOfWork commit.
    self assert: (unitOfWork numberOfRows) = 1.!

testDeleteRegistration
    | obj |
    obj := Object new.
    unitOfWork delete: obj.
    self assert: (unitOfWork willDelete: obj).
    self deny: (unitOfWork willDelete: 3).!

testDeletesComeAfterUpdates
    unitOfWork delete: GlorpAddress example1.
    unitOfWork register: GlorpCustomer example1.
    unitOfWork commit.
    self assert: unitOfWork session rows last table == (self tableNamed: 'GR_ADDRESS').!

testDeletesInReverseOrder
    "Not that good a test, because it could be luck with only two tables. Should test this at a lower level"
    | cust trans |
    cust := GlorpCustomer example2.
    trans := cust transactions first.
    unitOfWork delete: cust.
    unitOfWork delete: trans.
    unitOfWork commit.
    self assert: unitOfWork session rows last owner == cust.
    self assert: (unitOfWork session rows reverse at: 2) owner == trans.!

testGeneratingDeleteRows
    unitOfWork delete: GlorpAddress example1.
    unitOfWork createRows.
    self assert: unitOfWork privateGetRowMap numberOfEntries = 1.
    unitOfWork rowsForTable: (self tableNamed: 'GR_ADDRESS')
    	do: [:each | self assert: each forDeletion]! !

!GlorpDeleteInUnitOfWorkTest methodsFor: 'As yet unclassified'!

system
    ^unitOfWork session system.!

tableNamed: aString 
    ^self system tableNamed: aString.! !

!GlorpDeleteInUnitOfWorkTest methodsFor: 'support'!

setUp
    | session |
    session := GlorpMockSession new.
    session beginUnitOfWork.
    unitOfWork := session privateGetCurrentUnitOfWork.
    session system: (GlorpDemoDescriptorSystem forPlatform: GlorpDatabaseLoginResource defaultLogin database)!

tearDown
    unitOfWork := nil.! !

!GlorpDeleteInUnitOfWorkTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpMockSession methodsFor: 'accessing'!

accessor
    ^GlorpMockAccessor new.!

rows
    ^rows.! !

!GlorpMockSession methodsFor: 'initialize'!

initialize
    super initialize.
    rows := OrderedCollection new.! !

!GlorpMockSession methodsFor: 'read/write'!

writeRow: aRow
    aRow shouldBeWritten ifFalse: [^self].
    aRow preWriteAssignSequencesUsing: self.
    rows add: aRow.
    aRow postWriteAssignSequencesUsing: self.! !

!GlorpMockSession class methodsFor: 'instance creation'!

new
    ^super new initialize.! !

!GlorpMockSession class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpReadingDifferentCollectionsThroughMappingsTest methodsFor: 'setup'!

setUp
    super setUp.
    session := GlorpSessionResource current newSession.
    system := GlorpCollectionTypesDescriptorSystem forPlatform: session platform.
    session system: system.
    session beginTransaction.!

tearDown
    super tearDown.
    session rollbackTransaction.!

writeMore
    | other |
    session transact: [
    	session register: GlorpThingWithLotsOfDifferentCollections example1.
    	other := GlorpThingWithLotsOfDifferentCollections example1.
    	other name: 'barney'.
    	session register: other].!

writeRows
    session transact: [
    	session register: GlorpThingWithLotsOfDifferentCollections example1].! !

!GlorpReadingDifferentCollectionsThroughMappingsTest methodsFor: 'tests'!

testReadBack
    | thing list |
    self writeRows.
    session reset.
    list := session readManyOf: GlorpThingWithLotsOfDifferentCollections.
    self assert: list size = 1.
    thing := list first.
    self assert: thing array size = 3.
    self
    	assert:
    		(self validateFor: thing array against: #('array1' 'array2' 'array3')).
    self assert: thing array yourself class = Array.
    self assert: thing set size = 2.
    self assert: thing set yourself class = Set.
    self assert: (self validateFor: thing set against: #('set1' 'set2')).
    self assert: thing orderedCollection size = 2.
    self assert: thing orderedCollection yourself class = OrderedCollection.
    self
    	assert:
    		(self
    			validateFor: thing orderedCollection
    			against: #('orderedCollection1' 'orderedCollection2')).
    self assert: thing orderedCollection first name = 'orderedCollection1'.
    self assert: thing bag size = 2.
    self assert: thing bag yourself class = Bag.
    self assert: (self validateFor: thing bag against: #('bag1' 'bag2')).
    self assert: thing sortedCollection size = 4.
    self assert: thing sortedCollection yourself class = SortedCollection.
    self assert:
    		(thing sortedCollection collect: [:each | each name]) asArray
    			= #('sorted1' 'sorted2' 'sorted3' 'sorted4').!

testReadBackOneOfSeveral
    | thing list |
    self writeMore.
    session reset.
    list := session readManyOf: GlorpThingWithLotsOfDifferentCollections where: [:each | each name = 'fred'].
    self assert: list size = 1.
    thing := list first.
    self assert: thing array size = 3.
    self
    	assert:
    		(self validateFor: thing array against: #('array1' 'array2' 'array3')).
    self assert: thing array yourself class = Array.
    self assert: thing set size = 2.
    self assert: thing set yourself class = Set.
    self assert: (self validateFor: thing set against: #('set1' 'set2')).
    self assert: thing orderedCollection size = 2.
    self assert: thing orderedCollection yourself class = OrderedCollection.
    self
    	assert:
    		(self
    			validateFor: thing orderedCollection
    			against: #('orderedCollection1' 'orderedCollection2')).
    self assert: thing bag size = 2.
    self assert: thing bag yourself class = Bag.
    self assert: (self validateFor: thing bag against: #('bag1' 'bag2')).
    self assert: thing sortedCollection size = 4.
    self assert: thing sortedCollection yourself class = SortedCollection.
    self assert:
    		(thing sortedCollection collect: [:each | each name]) asArray
    			= #('sorted1' 'sorted2' 'sorted3' 'sorted4').!

testReadCollectionWithOrder
    | thing list |
    session transact: [session register: GlorpThingWithLotsOfDifferentCollections exampleForOrdering].
    session reset.
    list := session readManyOf: GlorpThingWithLotsOfDifferentCollections.
    self assert: list size = 1.
    thing := list first.
    self assert: thing orderedCollection size = 6.
    self
    	assert:
    		(thing orderedCollection collect: [:each | each name]) asArray = #('oc6' 'oc5' 'oc4' 'oc3' 'oc7' 'oc8')!

testReadManyToManyWithOrder
    | thing list |
    session transact: [session register: GlorpThingWithLotsOfDifferentCollections exampleForOrdering].
    session reset.
    list := session readManyOf: GlorpThingWithLotsOfDifferentCollections.
    self assert: list size = 1.
    thing := list first.
    self assert: thing orderedCollection size = 6.
    self
    	assert:
    		(thing orderedCollection collect: [:each | each name]) asArray = #('oc6' 'oc5' 'oc4' 'oc3' 'oc7' 'oc8')!

testReadOneToManyWithOrder
    | thing list |
    session transact: [session register: GlorpThingWithLotsOfDifferentCollections exampleForOrdering].
    session reset.
    list := session readManyOf: GlorpThingWithLotsOfDifferentCollections.
    self assert: list size = 1.
    thing := list first.
    self assert: thing array size = 6.
    self
    	assert:
    		(thing array collect: [:each | each name]) asArray = #('a1' 'a2' 'a3' 'a9' 'a8' 'a7')!

validateFor: aCollection against: expectedArrayContents
    ^(aCollection collect: [:each | each name]) asSortedCollection asArray
    	= expectedArrayContents.! !

!GlorpManyToManyDBTest methodsFor: 'tests-join'!

testReadCustomerOrderByLinkTableField
    | customers |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		customers := session readManyOf: GlorpCustomer.
    		customers do: [:each | | sortedAccounts |
    			sortedAccounts := each accounts asSortedCollection: [:a :b | a id <= b id].
    			self assert: each accountsSortedById asArray = sortedAccounts asArray]].!

testReadCustomerOrderByLinkTableFieldDescending
    | customers |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		customers := session readManyOf: GlorpCustomer.
    		customers do: [:each | | sortedAccounts |
    			sortedAccounts := each accounts asSortedCollection: [:a :b | a id <= b id].
    			self assert: each accountsSortedByIdDescending asArray = sortedAccounts asArray reverse]].!

testReadCustomerWithJoinToAccounts
    | customers |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		customers := session
    			readManyOf: GlorpCustomer
    			where:
    				[:eachCustomer | 
    				eachCustomer accounts
    					anySatisfy: [:eachAccount | eachAccount accountNumber bankCode = '2']].
    		self assert: customers size = 2].!

testReadCustomerWithJoinToAccounts2
    | customers |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		customers := session
    			readManyOf: GlorpCustomer
    			where:
    				[:eachCustomer | 
    				eachCustomer accounts
    					anySatisfy: [:eachAccount | eachAccount accountNumber branchNumber = 3]].
    		self assert: customers size = 1].!

testReadCustomerWithSimpleJoinToAccounts
    | customers |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		customers := session
    			readManyOf: GlorpCustomer
    			where:
    				[:eachCustomer | 
    				eachCustomer accounts
    					anySatisfy: [:eachAccount | eachAccount id <> 12]].
    		self assert: customers size = 2].! !

!GlorpManyToManyDBTest methodsFor: 'tests-read'!

checkNumberOfAccounts: anInteger
    | accountRows |
    accountRows := session accessor
    	executeSQLString: 'SELECT * FROM BANK_ACCT'.
    self assert: accountRows size = anInteger.!

checkNumberOfLinkRows: anInteger
    | linkRows |
    linkRows := session accessor
    	executeSQLString: 'SELECT * FROM CUSTOMER_ACCT_LINK'.
    self assert: linkRows size = anInteger.!

testReadCustomerAndAddAccount
    self
    	inTransactionDo:
    		[
    		self 
    			inUnitOfWorkDo: [customer addAccount: (GlorpBankAccount new id: 77473)]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId3 := 77473.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 4].!

testReadCustomerAndDeleteAccount
    "Note that delete, without also changing the relationships in memory, leaves a dangling link row. Some databases will fail the operation as a result. The VW oracle connect seems to have a problem here that this will sometimes leave subsequent tests looking at invalid data. The transaction appears to rollback, and the database appears fine, but somehow I'm getting erratic constraint failures. Ignoring for the moment, and just commenting out this test"
    self
    	inTransactionDo:[
    		[self 
    			inUnitOfWorkDo: [ | account| 
    				account := customer accounts detect: [:each | each id = 9874].
    				session delete: account]
    			initializeWith: [self writeCustomerWithAccounts]]
    			on: Error
    			do: [:ex | Transcript show: 'integrity violation'; nl.^self].
    		self readCustomer.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 3.
    		self checkNumberOfAccounts: 2].!

testReadCustomerAndDeleteAccountProperly
    "Do both the delete and the patching up of relationships"
    self
    	inTransactionDo:
    		[
    		self 
    			inUnitOfWorkDo: [ | account| 
    				account := customer accounts detect: [:each | each id = 9874].
    				session delete: account.
    				customer removeAccount: account]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 2.
    		self checkNumberOfAccounts: 2].!

testReadCustomerAndRemoveAccount
    self
    	inTransactionDo:
    		[self
    			inUnitOfWorkDo:
    				[| account |
    				account := customer accounts detect: [:each | each id = 9874].
    				customer accounts remove: account]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 2].!

testReadCustomerAndReplaceAccounts
    self
    	inTransactionDo:
    		[self
    			inUnitOfWorkDo:
    				[| account |
    				account := GlorpBankAccount new id: 99999.
    				customer accounts do: [:each | each accountHolders remove: customer].
    				customer accounts: (Array with: account)]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId1 := 99999.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 2.
    		self checkNumberOfAccounts: 4].!

testReadCustomerAndReplaceAccountsWithoutInstantiatingHolders
    "This works, but only fortuitously. If the accounts haven't been read into memory, we don't have to remove their object-level references to the account holder, because changing one side of the relationship in memory is enough to cause the link rows to be deleted"
    self
    	inTransactionDo:
    		[self
    			inUnitOfWorkDo:
    				[| account |
    				account := GlorpBankAccount new id: 99999.
    				customer accounts: (Array with: account)]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId1 := 99999.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 2.
    		self checkNumberOfAccounts: 4].!

testReadCustomerAndReplaceAccountsWithRemoval
    self
    	inTransactionDo:
    		[self
    			inUnitOfWorkDo:
    				[| account |
    				account := customer accounts detect: [:each | each id = 6].
    				customer accounts: (Array with: account)]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 2].!

testReadCustomerAndReplaceInstantiatedAccountsWithEmpty
    self
    	inTransactionDo:
    		[self
    			inUnitOfWorkDo:
    				[customer accounts yourself. 
    				customer accounts: #()]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId1 := nil.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 1.
    		self checkNumberOfAccounts: 3].!

testReadCustomerAndReplaceUninstantiatedAccountsWithEmpty
    self
    	inTransactionDo:
    		[self
    			inUnitOfWorkDo:
    				[customer accounts: #()]
    			initializeWith: [self writeCustomerWithAccounts].
    		self readCustomer.
    		accountId1 := nil.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfLinkRows: 1.
    		self checkNumberOfAccounts: 3].! !

!GlorpManyToManyDBTest methodsFor: 'tests-write'!

testWriteCustomerWithAccounts
    | newCustomer |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		session beginUnitOfWork.
    		newCustomer := GlorpCustomer example1.
    		newCustomer id: 12.
    		customerId := 12.
    		newCustomer accounts: (OrderedCollection with: (GlorpBankAccount new id: 223)).
    		session register: newCustomer.
    		session commitUnitOfWork.
    		session reset.
    		self readCustomer.
    		accountId1 := 223.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfAccounts: 4.
    		self checkNumberOfLinkRows: 4].!

testWriteCustomerWithNoAccounts
    | newCustomer |
    self
    	inTransactionDo:
    		[session beginUnitOfWork.
    		newCustomer := GlorpCustomer example1.
    		newCustomer id: 12.
    		customerId := 12.
    		session register: newCustomer.
    		session commitUnitOfWork.
    		session reset.
    		self readCustomer.
    		accountId1 := nil.
    		accountId2 := nil.
    		self checkAccounts.
    		self checkNumberOfAccounts: 0.
    		self checkNumberOfLinkRows: 0].!

testWriteCustomerWithTwoAccounts
    | newCustomer |
    self
    	inTransactionDo:
    		[self writeCustomerWithAccounts.
    		session beginUnitOfWork.
    		newCustomer := GlorpCustomer example1.
    		newCustomer id: 12.
    		customerId := 12.
    		newCustomer accounts: (OrderedCollection with: (GlorpBankAccount new id: 223)).
    		newCustomer accounts add: (GlorpBankAccount new id: 224).
    		session register: newCustomer.
    		session commitUnitOfWork.
    		session reset.
    		self readCustomer.
    		accountId1 := 223.
    		accountId2 := 224.
    		self checkAccounts.
    		self checkNumberOfAccounts: 5.
    		self checkNumberOfLinkRows: 5].! !

!GlorpManyToManyDBTest methodsFor: 'support'!

checkAccounts
    | sorted numberOfAccounts |
    numberOfAccounts := (accountId1 isNil ifTrue: [0] ifFalse: [1]) + (accountId2 isNil ifTrue: [0] ifFalse: [1]) + (accountId3 isNil ifTrue: [0] ifFalse: [1]).
    self assert: customer accounts size = numberOfAccounts.
    sorted := customer accounts asSortedCollection: [:a :b | a id <= b id].
    accountId1 isNil ifFalse: [self assert: sorted first id = accountId1].
    accountId2 isNil ifFalse: [self assert: (sorted at: 2) id = accountId2].
    accountId3 isNil ifFalse: [self assert: sorted last id = accountId3].
    self assert: (customer accounts collect: [:each | each id]) asSet size = customer accounts size.!

inUnitOfWorkDo: aBlock initializeWith: initBlock
    "Set up a bunch of the normal data, read the objects, then run the block in a unit of work"
    initBlock value.
    session beginUnitOfWork.
    self readCustomer.
    aBlock value.
    session commitUnitOfWork.
    session reset.!

readCustomer
    | results query |
    query := Query
    	returningManyOf: GlorpCustomer
    	where: [:cust | cust id = customerId].
    results := query executeIn: session.
    self assert: results size = 1.
    customer := results first.!

writeCustomerWithAccounts
    | customerRow accountRow1 accountRow2 linkRow1 linkRow2 customerRow2 accountRow3 linkRow3 |

    customerRow := session system exampleCustomerRow1.
    customerId := customerRow atFieldNamed: 'ID'.
    customerRow2 := session system exampleCustomerRow2.
    accountRow1 := session system exampleAccountRow1. 
    accountId2 := accountRow1 atFieldNamed: 'ID'.
    accountRow2 := session system exampleAccountRow2.
    accountId1 := accountRow2 atFieldNamed: 'ID'.
    accountRow3 := session system exampleAccountRow3.
    linkRow1 := session system exampleCALinkRow1.
    linkRow2 := session system exampleCALinkRow2.
    linkRow3 := session system exampleCALinkRow3.
    session writeRow: customerRow.
    session writeRow: customerRow2.
    session writeRow: accountRow1.
    session writeRow: accountRow2.
    session writeRow: accountRow3.
    session writeRow: linkRow1.
    session writeRow: linkRow2.
    session writeRow: linkRow3.! !

!GlorpManyToManyDBTest class methodsFor: 'As yet unclassified'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpTestNamespace.GlorpTestClassInNamespace class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDemoTablePopulatorResource methodsFor: 'setup'!

populateStuffTable
 
    login accessor executeSQLString: 'INSERT INTO STUFF VALUES (12,''abc'')'.
    login accessor executeSQLString: 'INSERT INTO STUFF VALUES (13, ''hey nonny nonny'')'.
    login accessor executeSQLString: 'INSERT INTO STUFF VALUES (42, ''yabba dabba doo'')'.
    login accessor executeSQLString: 'INSERT INTO STUFF VALUES (9625, ''the band played on'')'.
    login accessor executeSQLString: 'INSERT INTO STUFF VALUES (113141, ''Smalltalk'')'.!

setUp
    super setUp.
    login := GlorpDatabaseLoginResource current.
    self class needsSetup ifFalse: [^self].
    GlorpTestDescriptorSystem allSubclasses do: 
    		[:eachSystemClass | 
    		self 
    			setUpSystem: (eachSystemClass forPlatform: login platform) setUpDefaults].
    self populateStuffTable!

setUpSystem: system 
    | errorBlock |
    login accessor dropTables: system allTables.
    login accessor dropSequences: system allSequences.
    errorBlock := [:ex | Transcript show: ex description; nl. ex pass].
    system platform areSequencesExplicitlyCreated ifTrue: [
    	system allSequences do: [:each |
    		login accessor createSequence: each ifError: errorBlock]].
    system allTables do: [:each | 
    		login accessor createTable: each
    			ifError: errorBlock].
    system allTables do: [:each | 
    		login accessor createTableFKConstraints: each ifError: errorBlock].

    self class needsSetup: false! !

!GlorpDemoTablePopulatorResource class methodsFor: 'setup'!

invalidateSetup
    "GlorpDemoTablePopulatorResource invalidateSetup"

    NeedsSetup := true.
    self reset.!

needsSetup
    NeedsSetup isNil ifTrue: [NeedsSetup := true].
    ^NeedsSetup!

needsSetup: aBoolean
    NeedsSetup := aBoolean.!

resources
    ^Array with: GlorpDatabaseLoginResource.! !

!GlorpDemoTablePopulatorResource class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpEmailAddress methodsFor: 'accessing'!

host
    ^host!

host: anObject
    host := anObject!

id
    ^ id!

id: anInteger
     id := anInteger.!

user
    ^user!

user: anObject
    user := anObject! !

!GlorpEmailAddress methodsFor: 'printing'!

printOn: aStream
    super printOn: aStream.
    aStream nextPut: $(.
    aStream nextPutAll: id printString.
    aStream nextPut: $).! !

!GlorpEmailAddress class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpRowMapUnificationTest methodsFor: 'tests'!

testDoubleRowUnificationDifferentRows
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f3 with: f2)
    	correspondingTo: (Array with: o3 with: o2)
    	in: rowMap.
    (rowMap rowForTable: t1 withKey: o1) at: f1 put: 42.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 42.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 42.
    self assert: ((rowMap rowForTable: t3 withKey: o3) at: f3) = 42.!

testDoubleRowUnificationDifferentRows2
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f2 with: f3)
    	correspondingTo: (Array with: o2 with: o3)
    	in: rowMap.
    (rowMap rowForTable: t1 withKey: o1) at: f1 put: 42.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 42.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 42.
    self assert: ((rowMap rowForTable: t3 withKey: o3) at: f3) = 42.!

testDoubleRowUnificationDifferentRows3
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f2 with: f3)
    	correspondingTo: (Array with: o2 with: o3)
    	in: rowMap.
    (rowMap rowForTable: t3 withKey: o3) at: f3 put: 42.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 42.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 42.
    self assert: ((rowMap rowForTable: t3 withKey: o3) at: f3) = 42.!

testDoubleRowUnificationDifferentRows4
    | t4 f4 o4 |
    t4 := DatabaseTable named: 'T4'.
    f4 := t4 createFieldNamed: 'f4' type: (platform varChar: 10).
    o4 := 'four'.

    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f3 with: f4)
    	correspondingTo: (Array with: o3 with: o4)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f2 with: f3)
    	correspondingTo: (Array with: o2 with: o3)
    	in: rowMap.
    (rowMap rowForTable: t1 withKey: o1) at: f1 put: 42.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 42.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 42.
    self assert: ((rowMap rowForTable: t3 withKey: o3) at: f3) = 42.
    self assert: ((rowMap rowForTable: t4 withKey: o4) at: f4) = 42.!

testDoubleRowUnificationSameRow
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    (rowMap rowForTable: t1 withKey: o1) at: f1 put: 42.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 42.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 42!

testDoubleRowUnificationSameRow2
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f2 with: f1)
    	correspondingTo: (Array with: o2 with: o1)
    	in: rowMap.
    (rowMap rowForTable: t1 withKey: o1) at: f1 put: 42.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 42.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 42!

testIteration
    | rows r1 r2 r3 count |
    r1 := rowMap findOrAddRowForTable: t1 withKey: o1.
    r2 := rowMap findOrAddRowForTable: t1 withKey: o2.
    r3 := rowMap findOrAddRowForTable: t2 withKey: o2.
    rows := IdentitySet new.
    count := 0.
    rowMap rowsDo: [:each | 
    	count := count + 1.
    	rows add: each].
    self assert: count = 3.
    self assert: (rows includes: r1).
    self assert: (rows includes: r3).
    self assert: (rows includes: r2).!

testStoreThenUnify
    (rowMap findOrAddRowForTable: t1 withKey: o1) at: f1 put: 12.
    FieldUnifier 
    	unifyFields: (Array with: f2 with: f3)
    	correspondingTo: (Array with: o2 with: o3)
    	in: rowMap.
    FieldUnifier 
    	unifyFields: (Array with: f1 with: f2)
    	correspondingTo: (Array with: o1 with: o2)
    	in: rowMap.
    self assert: ((rowMap rowForTable: t1 withKey: o1) at: f1) = 12.
    self assert: ((rowMap rowForTable: t2 withKey: o2) at: f2) = 12.
    self assert: ((rowMap rowForTable: t3 withKey: o3) at: f3) = 12.!

testStoreWithRowMapKey
    | a b key1 key2 key3 table r1 r2 r3 |
    a := Object new.
    b := Object new.
    key1 := RowMapKey new key1: a; key2: b.
    key2 := RowMapKey new key1: a; key2: b.
    key3 := RowMapKey new key1: b; key2: a.
    table := DatabaseTable new.

    r1 := rowMap findOrAddRowForTable: table withKey: key1.
    r2 := rowMap findOrAddRowForTable: table withKey: key2.
    r3 := rowMap findOrAddRowForTable: table withKey: key3.

    self assert: r1 == r2.
    self assert: r2 == r3.
    self assert: r1 owner == key1.! !

!GlorpRowMapUnificationTest methodsFor: 'support'!

setUp
    super setUp.
    platform := GlorpDatabaseLoginResource defaultPlatform.
    t1 := DatabaseTable named: 'T1'.
    t2 := DatabaseTable named: 'T2'.
    t3 := DatabaseTable named: 'T3'.
    f1 := t1 createFieldNamed: 'f1' type: (platform varChar: 10).
    f2 := t2 createFieldNamed: 'f2' type: (platform varChar: 10).
    f3 := t3 createFieldNamed: 'f3'  type: (platform varChar: 10).
    rowMap := RowMap new.
    o1 := 'one'.
    o2 := 'two'.
    o3 := 'three'.! !

!GlorpRowMapUnificationTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpInt2Test methodsFor: 'tests'!

testBooleanToInteger
    stType := Boolean.
    self helpTestValue: nil.
    self helpTestValue: true.
    self helpTestValue: false.!

testInt2
    self helpTestValue: nil.
    self helpTestValue: 32123.! !

!GlorpInt2Test methodsFor: 'types'!

defaultDatabaseType
    ^self platform int2.! !

!GlorpInt2Test class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpObjectTransactionTest methodsFor: 'tests'!

testArray
    | object |
    object := #(1 2 3 4 5) copy.
    transaction begin.
    transaction register: object.
    object
    	at: 1 put: #one;
    	at: 2 put: object.
    transaction abort.
    self
    	assert: (object at: 1) == 1;
    	assert: (object at: 2) == 2!

testBecome
    | object |
    object := 'hello' copy.
    transaction begin.
    transaction register: object.
    object become: Set new.
    transaction abort.
    self 
    	assert: object class == '' class;
    	assert: object = 'hello'.!

testCommit
    | array |
    array := #(1 2 3 4 5) copy.
    transaction begin.
    transaction register: array.
    array
    	at: 1 put: #one;
    	at: 2 put: array.
    transaction commit.
    self
    	assert: (array at: 1) == #one;
    	assert: (array at: 2) == array!

testHashedCollection
    | object originalMembers |
    object := Set new.
    originalMembers := #(#one #two #three 'four' 5 'vi' (1 2 3 4 5 6 7)) collect: [:each | each copy].
    object addAll: originalMembers.
    transaction begin.
    transaction register: object.
    object remove: #one; remove: (originalMembers at: 4).
    object add: 1.
    originalMembers last at: 7 put: 'seven'.
    transaction abort.
    self
    	assert: object size = originalMembers size;
    	assert: (object includes: originalMembers first);
    	assert: (object includes: (originalMembers at: 4));
    	assert: object size = (object rehash; size).
    originalMembers do: [:each | self assert: (object includes: each)]!

testString
    | object |
    object := 'Hello, World!' copy.
    transaction begin.
    transaction register: object.
    object
    	at: 1 put: $h;
    	at: 2 put: $E.
    transaction abort.
    self
    	assert: object first  == $H;
    	assert: (object at: 2) == $e! !

!GlorpObjectTransactionTest methodsFor: 'support'!

setUp
    transaction := ObjectTransaction new! !

!GlorpObjectTransactionTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpDateTest methodsFor: 'tests'!

testDate
    | date |
    date := Date today.

    self helpTestValue: date.
    self helpTestValue: nil.! !

!GlorpDateTest methodsFor: 'types'!

defaultDatabaseType
    ^self platform date! !

!GlorpDateTest class methodsFor: 'LICENSE'!

LICENSE
    ^'Copyright 2000-2003 Alan Knight.
This class is part of the GLORP system (see http://www.glorp.org), licensed under the GNU Lesser General Public License, with clarifications with respect to Smalltalk library usage (LGPL(S)). This code is distributed WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE . See the package comment, or the COPYING.TXT file that should accompany this distribution, or the GNU Lesser General Public License.'! !

!GlorpVirtualCollectionBasicTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource.! !

!GlorpQueryCopyingTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpSessionResource.! !

!GlorpReadingDifferentCollectionsThroughMappingsTest class methodsFor: 'resources'!

resources
    ^Array with: GlorpDatabaseLoginResource with: GlorpDemoTablePopulatorResource with: GlorpSessionResource.! !

!TestCase methodsFor: 'Accessing'!

unfinished
    "indicates an unfinished test"! !
