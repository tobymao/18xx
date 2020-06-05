if (typeof setTimeout === 'undefined') { var setTimeout = function setTimeout(func) { } }

if (typeof window === 'undefined') {
  window = {
    addEventListener: function() {},
    matchMedia: function() { return {} },
    requestAnimationFrame: function() {},
    scrollTo: function() {},
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
