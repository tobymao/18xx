# frozen_string_literal: true

module G18CubaSpecHelpers
  def act(klass, entity = game.current_entity, **args)
    game.process_action(klass.new(entity, **args)).maybe_raise!
  end

  def depot_train(name)
    game.depot.depot_trains.find { |t| t.name == name } ||
      game.depot.upcoming.find { |t| t.name == name }
  end

  def give_train(corp, name)
    train = depot_train(name)
    return nil unless train

    game.depot.remove_train(train)
    train.owner = corp
    corp.trains << train
    train
  end
end
