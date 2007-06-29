"=====================================================================
|
|   Just a Database Manager - A simple example
|
|
 ======================================================================"

| value resultSet statement spec connection |

spec :=    (Jdm.JdmConnectionSpec new initialize
        user: 'root'; password: '';
        host: 'philo';
        database: 'mysql';
        port: 3306).

connection := Jdm.MySQL.JdmConnection on: spec.
statement := connection createStatement.

resultSet := (statement executeQuery: 'select * from db') value.

Transcript nl; show: (resultSet columns collect: [:col | col name]) printString.

[resultSet next]
whileTrue:
[
	value := resultSet valueNamed: 'Db'. "get column named Db"
	Transcript nl; show: value printString.
].
Transcript nl.

connection close!
