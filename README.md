# BestEvidence

### TripDatabase

The TripDatabase API provide a list of papers where the user can search and collect evidences linked to a specific query.

- search with the following endpoint format:
```
/search/json?criteria=list+of+keywords
```

- display results example:
```
{
  "total":66714,
  "count":20,
  "skip":0,
  "documents":
  [
  {
    "id":"9310808",
    "title":"UN-Water global analysis and assessment of sanitation and drinking-water (GLAAS) 2017 report: financing universal water, sanitation and hygiene under the sustainable development goals",
    "link":"http://www.who.int/iris/handle/10665/254999",
    "doi":"",
    "contenttype":"htm",
    "categoryid":1,
    "publicationid":4887518,
    "publication":"WHO",
    "pubdate":"Sun,01 Jan 2017 00:00:00 GMT"},
    ...
```

- Pagination:
  The "total", "count" and "skip" values of the response allow the application to display a pagination

With a simple UI searching for a keyword with the TripDatabase API, displaying the results and creating a pagination should be straingtforward and a first implemention can be done in 3/4 days

see https://best-evidence.herokuapp.com/ for a prototype version

# Voice search

In a stressful environment a speech to text feature can allow user to create quickly search keywords.
Depending on whi

## Voice recognition provided by the phone

**Work on mobile (Android and Iphone). Does not work on desktop**

**1/2 day implemention**

This is the quickest and a ready to go solution. When a text input is selected, the user has the choice to type of to use the microphone to enter text:

![microphone](/img/best-evidence.jpg)

## Google Speech API

**work on chrome and firefox (desktop and mobile). Does not work on Safari (Desktop and mobile)**

**5 to 1 sprint implemention time**

The idea is to use [getUserMedia()](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia) and the [Google Speech API](https://cloud.google.com/speech/) to record and convert to text the user voice. This solution is more complicated as it require more technical and detailed implemention.

## Native application

Create the two specific native applications for Android and Iphone. This implemention might be time consuming for an mvp as it will need to duplicate the application for each platforms.

- beta publish (2000 user tests) - 3 days to publish
- publish the finished application can take one week

So the estimation time is directly linked on which platform the voice recognition should be implemented:
- on mobile only this can be done quickly with the first solution
- on mobile and desktop (except Safari on desktop), the implementation can take up to one sprint

# Backend feature  

The main features can be implemented directly with Phoenix and Postgres:

## User account - 1 day

- guest account
- signup
- login/logout

## Save searches- 1 day

- save guest searches
- save user searches
- save user favorite searches

## Analytics - 1 day

- add google Analytics
- stats about searches, ex: number of searches

## Text notes

- save user notes in Postgres

# Audio notes

This feature will be based on [getUserMedia()](https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia) which only work on Chrome. Unfortunately the only way I think at the moment this feature can work on iOS is by creating a native app.

For an MVP version:
- do we want audio notes feature on desktop?
- Is this feature high priority on mobile?

Another solution is to upload an audio file that the users have created on their mobile with another application. Uploading a file will be an easier solution to implement (2/3 days)

