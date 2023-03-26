# frozen_string_literal: true

require 'user_manager'

module View
  class About < Snabberb::Component
    include UserManager

    needs :needs_consent, default: false
    needs :connection, store: true, default: nil

    def render
      @connection&.get('/version.json', '/assets') do |version|
        version_localtime = Time.at(version['version_epochtime'].to_i)
        link = node_to_s(h(:a, { attrs: { href: version['url'] } }, version['hash']))
        `document.getElementById('version').innerHTML = #{link}`
        `document.getElementById('version_localtime').innerHTML = #{version_localtime}`
      end

      message = <<~MESSAGE
        <h2>About 18xx.Games</h2>

        <p>
        18xx.Games is created and maintained by Toby Mao. It is an open source project, and you can find the
        code on <a href='https://github.com/tobymao/18xx/issues'>GitHub</a>. All games are used with express written consent from their respective rights holders. You can find more information about the games on the <a href='https://github.com/tobymao/18xx/wiki'>wiki</a>.
        </p>

        <p>Current version: <span id='version'>unknown</span> deployed at <span id='version_localtime'>unknown</span> (<a href="https://github.com/tobymao/18xx/commits/master">View all recent commits</a>)</p>

        <h2>Conduct Expectations</h2>

        <p>
        Be nice. Treat people with respect.
        </p>

        <h2>Privacy Policy</h2>

        <p>
        Upon your request and expression of consent, we collect the following data for the purpose of providing services to you. It is removed upon your request to terminate these services.
        </p>

        <p>
        <b>Email Addresses</b> are collected in order to send notifications. These notifications can be disabled in the #{@user ? "<a href=\"/profile/#{@user['id']}\">profile</a>" : 'profile'} page. Emails are not publicly available and not shared to any 3rd party except when email notifications are enabled. Emails are sent using the <a href='https://elasticemail.com'>Elastic Email</a> service.
        </p>

        <p>
        <b>IP Addresses</b> are collected when you use the site in order to prevent malicious behavior. These are not publicly available and not shared to any 3rd party.
        </p>

        <p>
        <b>Game Data</b> is collected when you play a game and is needed for the game to function. Game Data is publicly available through the website interface and API. In-game messages are only visible to the players in the game (whether via the website or the API).
        </p>

        <p>
        <b>Local Storage</b> is used to store local data like hot seat games and master mode. This can only be accessed by your device.
        </p>

        <p>
        For questions or requests please file an issue on <a href='https://github.com/tobymao/18xx/issues'>GitHub</a>.
        </p>

        <H2>Special thanks to all the contributors.</H2>
        <a href='https://github.com/michaeljb'>michaeljb</a>
        <a href='https://github.com/jenf'>jenf</a>
        <a href='https://github.com/yzemaze'>yzemaze</a>
        <a href='https://github.com/dfannius'>dfannius</a>
        <a href='https://github.com/kelsin'>kelsin</a>
        <a href='https://github.com/talbatross'>talbatross</a>
        <a href='https://github.com/scottredracecar'>scottredracecar</a>
        <a href='https://github.com/perwestling'>perwestling</a>
        <a href='https://github.com/roseundy'>roseundy</a>
        <a href='https://github.com/ryandriskel'>ryandriskel</a>
        <a href='https://github.com/crericha'>crericha</a>
        <a href='https://github.com/ventusignis'>ventusignis</a>
        <a href='https://github.com/tysen'>tysen</a>
        <a href='https://github.com/daniel-sousa-me'>daniel-sousa-me</a>
        <a href='https://github.com/benjaminxscott'>benjaminxscott (dstar)</a>

        <p>This website will always be open-source and free to play. If you'd like support this project, you can become a patron on
        <a href='https://www.patreon.com/18xxgames'>Patreon</a>.</p>
      MESSAGE

      children = [h(:div, props: { innerHTML: message })]

      if @needs_consent
        @confirmation = h(:input, attrs: { placeholder: 'Type DELETE to confirm' })

        children << h(:div, [
          h(:h2, 'In order to continue using your account, you must give consent'),
          h(:button, { on: { click: -> { consent } } }, 'I agree to the privacy policy'),
          h(:button, { on: { click: -> { delete } } }, 'Delete my account and all data'),
          @confirmation,
        ])
      end

      h('div#about', children)
    end

    def consent
      edit_user(consent: true)
      store(:app_route, '/')
    end

    def delete
      return store(:flash_opts, 'Confirmation not correct') if Native(@confirmation).elm.value != 'DELETE'

      delete_user
    end
  end
end
