module OrganizationBrandingHelper

  def org_inline_color(organization)
    background = organization.display_brand_color
    foreground = organization.offset_brand_color
    %(
      style="
        background-color: #{background};
        color: #{foreground};
      "
    ).html_safe
  end

  def org_inline_color_knockout(organization)
    background = organization.offset_brand_color
    foreground = organization.display_brand_color
    %(
      style="
        background-color: #{background};
        color: #{foreground};
      "
    ).html_safe
  end


end
