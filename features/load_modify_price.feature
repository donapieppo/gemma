Feature: Modifica del prezzo di un carico
  In order to change price af a previous load 
  the change should be propagated to the relative unloads

  Scenario: Modify Unload price 
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07 with price 100    
      # +10 10 -> 20
      And one unload unpippo1 of 2 in date 02-07              
      And one unload unpippo2 of 3 in date 03-07               
      And one load pluto of 20 in date 10-07 with price 20     
      # +20  1 (5 a 20 e 20 a 1)
      And one unload unpluto of 10 in date 11-07               
    When I change the price of pippo to 200                    
    Then price of unload unpippo1 is 40                       
     And price of unload unpippo2 is 60                      
     And price of unload unpluto is 105                     
     # 5*20 + 5*1 = 105

  Scenario: Modify Unload price with one load of zero price
   Given one organization with thing
      And organization has pricing on
      And one ddt in date 01-07
      And one load pippo of 10 in date 01-07 with price 100    
      #  10 a 10 -> 20
      And one unload unpippo1 of 2 in date 02-07               
      And one unload unpippo2 of 3 in date 03-07              
      And one load pluto of 20 in date 10-07                   
      #  20 a 0 ( 5 a 20 + 20 a 0)
      And one unload unpluto of 10 in date 11-07              
    When I change the price of pippo to 200                   
    Then price of unload unpippo1 is 40
     And price of unload unpippo2 is 60
     And price of unload unpluto is 100
     # 5*20 = 100

 
 
