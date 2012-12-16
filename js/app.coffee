App = Ember.Application.create()

Ember.Fetchable = Ember.Mixin.create
  fetchItems: ((max_id) ->
    _this = @
    return $.Deferred((defer) ->
      return $.ajax(
        url: _this.get('url'),
        dataType: 'json',
        data:
          after: max_id
      ).done((res) ->
        return defer.resolve(res.results)
      )
    ).promise()
  ),
  fetch: ((callback) ->
    _this = @
    @fetchItems(@get('maxId')).done((tweets) ->
      items = tweets.map((v) ->
        v['recent'] = true
        Ember.Object.create(v)
      ).reverse()
      _this.get('content').unshiftObjects(items)
      if callback
        callback()
    )
  )


# Controllers
App.tweets = Ember.ArrayController.create Ember.Fetchable,
  content: [],
  maxId: 3, # adhoc
  url: (->
    './item.json?after=' + @get('maxId')
  ).property('maxId'),
  recentCount: (->
    @get('content').filterProperty('recent', true).length
  ).property('content.@each.recent'),
  expandRecent: (->
    @get('content').forEach((v) ->
      v.set('recent', false)
    )
  )



# Views
App.ApplicationView = Ember.View.extend()

App.TwitterListView = Ember.View.extend
  templateName: 'twitter_list',
  contentBinding: 'App.tweets.content',
  recentCountBinding: 'App.tweets.recentCount',
  expandRecent: (->
    App.tweets.expandRecent()
  ),
  hasRecentItems: (->
    @get('recentCount') > 0
  ).property('recentCount'),
  items: (->
    @get('content').filterProperty('recent', false)
  ).property('content.@each.recent')

# Setup
setInterval((->
  if App.tweets.get('recentCount') < 10
    App.tweets.fetch()
), 5000)

App.tweets.fetch(->
  App.tweets.expandRecent()
)


