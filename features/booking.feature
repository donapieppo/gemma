Feature: Booking 
  In order to recive a Thing whith booking
  you have to make the booking, recive the thing, have the admn confirm

Scenario: Booking
  Given one organization with thing
  And one ddt in date 01-07
  And one load pippo of 10 in date 01-07
  And one load pluto of 12 in date 02-07
  And one booking cippa by a user of 12 in date 03-07
  When Admin confirms the book cippa
  Then there is no more booking by the user
  And there is an unload of 12 by the user today

