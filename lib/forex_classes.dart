class Trade
{

}

class Order
{

}

class Account
{
  String id;
  num balance;
  num Margin;

  List<Trade> OpenTrades;
  List<Trade> ClosedTrades;
  List<Order> OpenOrder;
  List<Order> ClosedOrder;
  Account()
  {
    balance=0;
    Margin =0;
  }
  num RealizedPL()
  {
    return balance;
  }

  num UnrealizedPL()
  {

  }

  num NetAssetValue()
  {

  }

  num MarginUsed()
  {

  }

  num MarginAvailable()
  {

  }

  void Deposit(num amt)
  {

  }

  void WithDraw(num amt)
  {

  }

  void ExecuteTrade(Trade newtrade)
  {

  }
}
class User
{
  String id;
  List<Account> Accounts;
  User(this.id)
  {
    Accounts=new List<Accounts>();
  }
  num RealizedPL()
  {
    num balance =0;
    for(Account acct in Accounts)
    {
      balance+=acct.RealizedPL();
    }

    return balance;
  }

  num UnRealizedPL()
  {
    num balance =0;
    for(Account acct in Accounts)
    {
      balance+=acct.UnrealizedPL();
    }
    return balance;
  }

  num MarginUsed()
  {
    num balance =0;
    for(Account acct in Accounts)
    {
      balance+=acct.MarginUsed();
    }

    return balance;
  }

  num MarginAvailable()
  {
    num balance =0;
    for(Account acct in Accounts)
    {
      balance+=acct.MarginAvailable();
    }
    return balance;
  }

  num NetAssetValue()
  {
    num balance =0;
    for(Account acct in Accounts)
    {
      balance+=acct.NetAssetValue();
    }
    return balance;
  }
}
