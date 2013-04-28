var OnTime = OnTime || {};

var Util = Util || {};

Util.hashVal = function() {
  return location.hash;
}

OnTime.init = function(options) {
  var api = options.api,
      that = this;

  this.averagePage = undefined;

  function init() {
    that.averagePage = new OnTime.AvgForAirlines({ url: api.delays });

    console.log('Initialized OnTime page');
  }

  init();

  return this;
};

OnTime.AvgForAirlines = function(options) {
  var $el = $('#average-page'),
      $viz = $el.find('#average-delay-viz'),
      $info = $('#indicator'),
      url = options.url || '',
      data = [],
      that = this;

  this.show = function() {
    if (hasData()) {
      _show();
    }
    else {
      loadData(_show);
    }
  };

  function hasData() {
    return data.length > 0;
  }

  function _show() {
    $viz.text(JSON.stringify(data));
  }

  function loadData(callback) {
    if (url === '') return;

    $info.show();

    $.get(url, function(response) {
      data = response;
      if (callback) {
        callback();
      }
    })
    .complete(function() {
      $info.hide();
    })
    .fail(function() {
      $('#error').show().text('Error while requesting data');
    });
  }

  function init() {
    $('a[href=#average-page]').click(function() {
      that.show();
    });

    console.log('Initialized OnTime.AvgForAirlines')
  }

  init();

  return this;
};
