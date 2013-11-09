"=====================================================================
|
|   PostgreSQL DBI driver unit tests
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2013 Free Software Foundation, Inc.
| Written by Holger Hans Peter Freyther
|
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
|
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
|
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.
|
 ======================================================================"


TestCase subclass: PostgresTestCase [
    | conn |
    <category: 'DBD-PostgreSQL-Tests'>
    <comment: 'I test some basic Postgres binding classes'>

    PostgresTestCase class >> schema [
        ^'CREATE TABLE GSTTypes(
                bigint BIGINT,
                bigserial BIGSERIAL,
                bit BIT,
                bitvar BIT VARYING,
                boolean BOOLEAN,
                box BOX,
                bytearray BYTEA,
                character_var CHARACTER VARYING,
                character CHARACTER,
                cidr CIDR,
                circle CIRCLE,
                date DATE,
                double DOUBLE PRECISION,
                inet INET,
                integer INTEGER,
                interval INTERVAL,
                line LINE,
                lseg LSEG,
                macaddr MACADDR,
                money MONEY,
                numeric NUMERIC,
                path PATH,
                point POINT,
                polygen POLYGON,
                real REAL,
                smallint INT2,
                serial SERIAL,
                text TEXT,
                time TIME,
                time_tz TIME WITH TIME ZONE,
                timestamp TIMESTAMP,
                timestamp_tz TIMESTAMP WITH TIME ZONE,
                tsquery TSQUERY,
                tsvector TSVECTOR,
                txid TXID_SNAPSHOT,
                uuid UUID,
                xml XML)'

    ]

    setUp [
        | user pass db |
        user := TestSuitesScripter variableAt: 'postgresuser' ifAbsent: [nil].
        pass := TestSuitesScripter variableAt: 'postgrespassword' ifAbsent: [nil].
        db := TestSuitesScripter variableAt: 'postgresdb' ifAbsent: ['gst'].

        conn := DBI.Connection
                connect: 'dbi:PostgreSQL:dbname=', db user: user password: pass.

        "Drop and create some tables"
        conn
            do: 'DROP TABLE IF EXISTS GSTTypes CASCADE';
            do: self class schema.
    ]

    tearDown [
        conn close.
    ]

    testNull [
        | statement res |

        "I attempt to insert a NULL"
        statement := conn prepare: 'INSERT INTO GSTTypes(bigint) VALUES($1)'.
        res := statement executeWithAll: {nil}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        res := conn do: 'SELECT * from GSTTypes WHERE bigint IS NULL'.
        self assert: res isSelect.
        self deny: res isDML.
        self assert: res rowCount = 1.

        self assert: (res next at: 'bigint') isNil.
    ]

    testInteger [
        | statement res |

        "I attempt to insert a number"
        statement := conn prepare: 'INSERT INTO GSTTypes(integer) VALUES($1)'.
        res := statement executeWithAll: {100}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        res := conn do: 'SELECT * from GSTTypes WHERE integer = 100'.
        self assert: res isSelect.
        self deny: res isDML.
        self assert: res rowCount = 1.

        self assert: (res next at: 'integer')  = 100.
    ]

    testDateTimeParse [
        | res |
        "Manually test if we can parse dates with ms"
        res := PGColumnInfo convertDateTime: '2013-11-08 16:53:03.11825'.
        self assert: res = (DateTime year: 2013 month: 11 day: 8 hour: 16 minute: 53 second: 3)
    ]

    testDateTime [
        | statement res now now_utc row |

        "Pick a date and time with timezone"
        now := DateTime now
                offset: (Duration hours: 3).

        statement := conn prepare:
                    'INSERT INTO GSTTypes(timestamp, timestamp_tz) VALUES($1,$2)'.
        res := statement executeWithAll: {now. now}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        res := conn do: 'SELECT * from GSTTypes'.
        self assert: res isSelect.
        self deny: res isDML.
        self assert: res rowCount = 1.

        row := res next.

        "Check that Postgres just dropped the offset from the timestamp we passed"
        self assert: (row at: 'timestamp') offset = Duration zero.
        self assert: (row at: 'timestamp') = (now offset: Duration zero).

        "Check that we can read the time back as it should be."
        self assert: (row at: 'timestamp_tz') = now.
    ]

    testBoolean [
        | statement res row |
        statement := conn prepare:
                    'INSERT INTO GSTTypes(boolean,integer) VALUES($1,$2)'.

        "Insert a true"
        res := statement executeWithAll: {true. 10}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        "Insert a false"
        res := statement executeWithAll: {false. 20}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        res := conn do: 'SELECT * from GSTTypes ORDER BY integer'.
        self assert: res isSelect.
        self deny: res isDML.
        self assert: res rowCount = 2.

        row := res next.
        self assert: (row at: 'integer') = 10.
        self assert: (row at: 'boolean').

        row := res next.
        self assert: (row at: 'integer') = 20.
        self deny: (row at: 'boolean').
    ]

    testTime [
        | statement res now |

        now := Time now.

        statement := conn prepare: 'INSERT INTO GSTTypes(time) VALUES($1)'.
        res := statement executeWithAll: {now}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        res := conn do: 'SELECT * from GSTTypes'.
        self assert: res isSelect.
        self deny: res isDML.
        self assert: res rowCount = 1.

        self assert: (res next at: 'time') = now.
    ]

    testTimeTz [
        "GST doesn't have a Timezone on the Time"
        | statement res now |

        now := Time now.
        statement := conn prepare: 'INSERT INTO GSTTypes(time_tz) VALUES($1)'.
        res := statement executeWithAll: {now}.
        self deny: res isSelect.
        self assert: res isDML.
        self assert: res rowsAffected = 1.

        res := conn do: 'SELECT * from GSTTypes'.
        self assert: res isSelect.
        self deny: res isDML.
        self assert: res rowCount = 1.

        self assert: (res next at: 'time_tz') = now.
    ]
]
