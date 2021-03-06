require 'active_support/core_ext/string'

module Lightspeed
  class AccountResources
    attr_accessor :account

    def initialize(account)
      @account = account
    end

    def all(params: {})
      response = get(params: params)
      account.instantiate(response[resource_name], Lightspeed.const_get(resource_name))
    end

    def find(id)
      id_key = "#{resource_name.camelize(:lower)}ID"
      params = { id_key => id }
      response = get(params: params)
      if response[resource_name]
        resource_class.new(account, response[resource_name])
      else
        raise Lightspeed::Errors::NotFound, "Could not find a #{resource_name} with #{id_key}=#{id}"
      end
    end

    def create(attributes = {})
      craft_instance(post(body: attributes.to_json))
    end

    def update(id, attributes = {})
      craft_instance(put(id, body: attributes.to_json))
    end

    def destroy(id)
      craft_instance(delete(id))
    end

    private

    def craft_instance(response)
      resource_class.new(client, response[resource_name])
    end

    def client
      account.client
    end

    def resource_class
      Lightspeed.const_get(resource_name)
    end

    def resource_name
      self.class.resource_name
    end

    def get(params: {})
      params.merge!(load_relations: "all")
      client.get(
        path: collection_path,
        params: params
      )
    end

    def post(body:)
      client.post(
        path: collection_path,
        body: body
      )
    end

    def put(id, body:)
      client.put(
        path: item_path(id),
        body: body,
      )
    end

    def delete(id)
      client.delete(
        path: item_path(id)
      )
    end

    def base_path
      "/Account/#{account.id}/#{self.class.resource_name}"
    end

    def collection_path
      base_path + ".json"
    end

    def item_path(id)
      base_path + "/#{id}.json"
    end
  end
end
