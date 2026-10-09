module ApplicationHelper
  def page_metadata(title: nil, description: nil, image: nil)
    content_for :title, title if title
    content_for :description, description if description
    content_for :image, image if image
  end

  def rubles(cents)
    whole, fractional = cents.divmod(100)
    "#{number_with_delimiter(whole, delimiter: " ")}.#{format("%02d", fractional)} ₽"
  end

  def icon(name, size: 20, class_name: "size-5")
    shapes = {
      arrow_right: [ tag.path(d: "M5 12h14"), tag.path(d: "m13 6 6 6-6 6") ],
      bag: [ tag.path(d: "M5 8h14l-1 12H6L5 8Z"), tag.path(d: "M9 8V6a3 3 0 0 1 6 0v2") ],
      check: [ tag.path(d: "m5 12 4 4L19 6") ],
      check_circle: [ tag.circle(cx: 12, cy: 12, r: 9), tag.path(d: "m8 12 3 3 5-6") ],
      chevron_right: [ tag.path(d: "m9 18 6-6-6-6") ],
      credit_card: [ tag.rect(x: 3, y: 5, width: 18, height: 14, rx: 2), tag.path(d: "M3 10h18"), tag.path(d: "M7 15h3") ],
      mail: [ tag.rect(x: 3, y: 5, width: 18, height: 14, rx: 2), tag.path(d: "m3 7 9 6 9-6") ],
      menu: [ tag.path(d: "M4 7h16"), tag.path(d: "M4 12h16"), tag.path(d: "M4 17h16") ],
      message: [ tag.path(d: "M20 11.5a7.5 7.5 0 0 1-8 7.5 8.8 8.8 0 0 1-3.5-.7L4 20l1.7-3.5A7.3 7.3 0 0 1 4 11.5 7.5 7.5 0 0 1 12 4a7.5 7.5 0 0 1 8 7.5Z") ],
      phone: [ tag.path(d: "M6 3h3l1.5 4-2 1.5a14 14 0 0 0 5 5l1.5-2 4 1.5v3c0 1-1 2-2 2A15 15 0 0 1 4 5c0-1 1-2 2-2Z") ],
      shield: [ tag.path(d: "M12 3 19 6v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6l7-3Z"), tag.path(d: "m9 12 2 2 4-4") ],
      sparkle: [ tag.path(d: "m12 3 1.5 5.5L19 10l-5.5 1.5L12 17l-1.5-5.5L5 10l5.5-1.5L12 3Z"), tag.path(d: "m19 16 .7 2.3L22 19l-2.3.7L19 22l-.7-2.3L16 19l2.3-.7L19 16Z") ],
      trash: [ tag.path(d: "M4 7h16"), tag.path(d: "M10 11v6M14 11v6"), tag.path(d: "m9 7 1-2h4l1 2"), tag.path(d: "M6 7l1 13h10l1-13") ],
      truck: [ tag.path(d: "M3 6h11v9H3z"), tag.path(d: "M14 9h4l3 3v3h-7"), tag.circle(cx: 7, cy: 18, r: 2), tag.circle(cx: 17, cy: 18, r: 2) ],
      user: [ tag.circle(cx: 12, cy: 8, r: 3), tag.path(d: "M5 20a7 7 0 0 1 14 0") ],
      wallet: [ tag.path(d: "M4 6h15a2 2 0 0 1 2 2v10H4a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2Z"), tag.path(d: "M2 8a2 2 0 0 1 2-2V4h13a2 2 0 0 1 2 2"), tag.path(d: "M16 13h2") ]
    }

    tag.svg(width: size, height: size, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 1.8, "stroke-linecap": "round", "stroke-linejoin": "round", class: class_name, aria: { hidden: true }) do
      safe_join(shapes.fetch(name))
    end
  end
end
