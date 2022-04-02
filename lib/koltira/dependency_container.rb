# frozen_string_literal: true

require_relative 'dependency_container/version'

module Koltira
  module DependencyContainer
    class Error < StandardError; end
    class DependencyNotFound < Error; end

    def di_container_repository
      @di_container_repository ||= {}
    end

    def di_instances
      Thread.current[:di_instances]
    end

    def di(name)
      instances = Thread.current[:di_instances]
      return instances[name] if !instances.nil? && instances.key?(name)

      Thread.current[:di_instances] ||= {}

      unless di_container_repository.key?(name)
        raise DependencyNotFound, "Dependency '#{name}' does not exists"
      end
      Thread.current[:di_instances][name] = di_container_repository[name].call
    end

    def with_dependency(name, &_block)
      yield(di(name))
    end

    def dependency(name, &block)
      di_container_repository[name] = block
    end
  end
end
