I have a ruby on rails application with this models

class Operation < ApplicationRecord
  belongs_to :thing

class Thing < ApplicationRecord
  has_many :operations

class Load < Operation

class Unload < Operation

each unload belongs to a thing and has a price and a number of things and a date
and represent the butuibg of things with a price.
For example a load can be of 10 oranges on 01-01-2025 for a total o 10 euro.

Each thing has many loads and unloads where unloads are operations
also with number and date and price.

The price of an unload is based on the previous loads.

For example 

  - 01/01/2025 load of 10 oranges for 10 euro (1 euro each)
  - 02/01/2025 load of 5 oranges for 10 euro (2 euro each)
  - 03/01/2025 unoad of 12 oranges

this last unload takes the 10 oranges at 1 euro each and 2 of the 5 oranfes at 2 eurios each
with a total price of 14 euros.

How would you manage the calculation of the price considering
a database with many records?
To get the prioce of a new unload there should be some 
oprimization to calculate the price without starting from the first loads and unloads.

You can add tebles or fields to the db in order tio have some cache 
if you need it
