# frozen_string_literal: true

class Api
  route 'game' do |r|
    r.is 'subscribe' do
      room = ROOMS[1]
      q = Queue.new
      room << q

      response['Content-Type'] = 'text/event-stream;charset=UTF-8'
      response['X-Accel-Buffering'] = 'no' # for nginx
      response['Transfer-Encoding'] = 'identity'

      stream(loop: true, callback: -> { on_close(room, q) }) do |out|
        out << "data: #{q.pop}\n\n"
      end
    end

    r.post 'action' do
      action = r.params
      ACTIONS << action
      notify(1, type: 'action', data: action)
      ''
    end

    r.post 'rollback' do
      ACTIONS.pop
      notify(1, type: 'refresh', data: ACTIONS)
      ''
    end

    r.post 'refresh' do
      { type: 'refresh', data: ACTIONS }
    end

    r.post do
      { 'test': 'success' }
    end

    r.get do
      render(app_route: r.path)
    end
  end
end
