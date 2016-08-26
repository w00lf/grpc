require 'active_model_serializers'
alias read_attribute_for_serialization send

class ComplexResponseSerializer < ActiveModel::Serializer
  attributes :time_spend, :response_bytes
  has_many :topics
end

class TopicSerializer < ActiveModel::Serializer
  attributes :id, :headline, :alternative_headline, :announce, :content_type, :dispatched_at, :is_visible, :partner_related, :preview_token, :published_at
  has_many :widgets
end

class WidgetSerializer < ActiveModel::Serializer
  attributes :id, :type, :data, :created_at, :updated_at, :position
end
