if (typeof setTimeout === 'undefined') { var setTimeout = function setTimeout(func) { } }

if (typeof window === 'undefined') {
  window = {
    requestAnimationFrame: function() {},
    scrollTo: function() {},
    addEventListener: function() {},
    location: {
      pathname: '',
      hash: '',
      search: ''
    },
    history: {
      pushState: function() {}
    }
  }
}

if (typeof localStorage === 'undefined') {
  localStorage = {
    getItem: function() {},
    setItem: function() {}
  }
}

if (typeof document === 'undefined') {
  document = {
  }
}

if (typeof XMLHttpRequest === 'undefined') { var XMLHttpRequest = function XMLHttpRequest() {} }
