module MarketplaceTaggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings

    after_save :sync_marketplace_tags, if: :marketplace_tag_list_assigned?
  end

  def marketplace_tag_list
    return @marketplace_tag_list if marketplace_tag_list_assigned?

    tags.order(:context, :name).map(&:qualified_name).join(", ")
  end

  def marketplace_tag_list=(value)
    @marketplace_tag_list_assigned = true
    @marketplace_tag_list = value.to_s
  end

  private

  def marketplace_tag_list_assigned?
    @marketplace_tag_list_assigned == true
  end

  def sync_marketplace_tags
    parsed_tags = @marketplace_tag_list.split(",").filter_map do |entry|
      context, name = entry.strip.split(":", 2)
      next if name.blank?

      Tag.find_or_create_by!(context: context.to_s.strip.parameterize(separator: "_"), slug: name.strip.parameterize) do |tag|
        tag.name = name.strip
      end
    end

    self.tags = parsed_tags.uniq
    @marketplace_tag_list_assigned = false
  end
end
