import
    httpclient, json, strformat, strutils, tables


const
    BaseAPIURL = "https://us.api.battle.net/wow/"
    ApiKey = "<YOUR API KEY>"

var 
    itemTable = newTable[Natural, string]()
    client = newHttpClient()


proc httpJson(url:string): JsonNode =
    parseJson(client.get(url).body)


proc apiCall(path: openArray[string]): JsonNode =
    let url = BaseAPIURL & path.join("/") & "?apikey=" & ApiKey
    url.httpJson


proc itemLookUp(id: Natural): string =
    result = fmt"Unknown Item Name: {id}"
    if itemTable.hasKey(id):
        result = itemTable[id]
    else:
        let item_date = apiCall(["item", id.intToStr])
        if item_date.hasKey("name"):
            result = item_date["name"].str
            itemTable[id] = result


proc main() =
    let realm = "Staghelm"
    echo fmt"Loading Data from {realm}'s Auction house!"
    let auctionUrl = apiCall(["auction", "data", realm])["files"][0]["url"].str
    let auctionData = httpJson(auctionUrl)
    for item in auctionData["auctions"]:
        echo itemLookUp(item["item"].num)

when isMainModule:
    main()