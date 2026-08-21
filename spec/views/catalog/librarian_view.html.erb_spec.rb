# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/librarian_view.html.erb" do
  context "when given an Alma marc source with AVA fields" do
    before do
      assign(:document, SolrDocument.new(id: "9922486553506421"))
    end
    it "displays the AVA fields" do
      allow(view).to receive(:params).and_return(id: "9922486553506421")
      stub_request(:get, "https://bibdata-staging.lib.princeton.edu/bibliographic/9922486553506421")
        .to_return(status: 200, body: File.open(Rails.root.join("spec", "fixtures", "alma", "9922486553506421_marc.xml")), headers: {})

      render

      expect(rendered).to have_selector ".subfields", text: "19990423000000.0"
      expect(rendered).to have_selector ".tag", text: "AVA"
    end
  end
  # rubocop:disable Layout/LineLength
  context "when deduplication feature is on and the record is a cluster record" do
    before do
      assign(:document, SolrDocument.new(id: "9912345678906421", 'cluster_members_s': [
                                                                   "9913079923506421",
                                                                   "SCSB-7773524",
                                                                   "SCSB-7773521",
                                                                   "SCSB-7773529"
                                                                 ],
                                         'cluster_members_display': [
                                           "{\"9913079923506421\":{\"display_format\":\"Book\"}}",
                                           "{\"SCSB-7773524\":{\"display_format\":\"EBook\"}}",
                                           "{\"SCSB-7773521\":{\"display_format\":\"Book\"}}",
                                           "{\"SCSB-7773529\":{\"display_format\":\"Book\"}}"
                                         ],
                                         'marcxml_bi': [
                                           "H4sIAAAAAAAA/81YbW/bNhD+KwcN6FbAlki9WXIcDYmbYR2cNIjTbkPRDrREW2wkUSPl2O6v3ylxX9a6lAoYw/JBEKzj8Z57ee4uE8VTqTLYlkWlT628aeqx42w2G7uQqb2S987l2c3UpY4uRGk9io23WvxLdOPZUq0clxDq/HE5m6c5L9lQVLphVcrxlBZj/fDjTKasEbLqugkOfG61ZUxl2imZStES51Hn/lx7zN7qzEomBWcZVwmhQRSlrATmomke9QDADwiZOHuBSSqrRsliKXiRQcNWpxZCsJI4ph4ZxbHrBST0XTpxPhc8fCywEpe4AaUkJJ4b+75N+hyLrGQUk8AjmkajERoIJVvDpz9CCJAFr1Zv336pLmMN+1wXJRaIKqOnFjy8uO1LMtHrxaNUKjN+ajErIT6hI+L7E+fDt2TifNT2tWIv6KM4tpLps1ckisPb+XE1o8k/Xb27froPyrBWAtOqkVW2OO5F7/cXvZI7tuJqf9/xwbyYytn0qUxLEhAaxnHY9wq/b4ifzaaf6/xCYGElmFEGgRRj+XJuEMAqezGdmQWuX8764gr64pqdh97IjMy+9KCtpZ53U/Lxbmq++5IpXuWyaN4Pz9dPfth6JDop5GYA51w1OYN7WQ3MHqERJUMaxZ5tkCNWsic/kX3kPrZucqlEI7h2Kla2T8zMyEU664kTRb/CSQ7ivOGlqIROORaZBrmEX5TgmRJpjm+SL3hhm1PnfAfndusO+IbLbLhVrNIFa3gGix1cKm3Dr1KxlOORqrLhd9HkwEDf8QavRRuanEMhlvygPa2Oi1IUO5jnQim+XNp9vRL2zbxzqRtzgDH3ZpzDE1bWJ2gIr7FXnRjkUekV38CfUt11qJ2iw2x4JopCVKuclQOz/9vs7+sAj/R1gAe1DRhDl1LvxB6AF8T4S5clkJZ9TQn6meJZycUW3+vd2Ozc6/WiEDrn6kcNLLvHIhWal7xq9Bhe+29aOKwBXmUmENjWsSP0ReDT4yFIWwQqzZnmHVk0Z/cSS07KOyyjKZpUyNWaY4DGcFZyLBRWwUW2fpy8OigKByW/d8BCetSAWcgDrf05wwYPr7VI38BvfMOLAiO4QHg2NBIWHF7//AYuMKC8abQ1HD6voETkyDdLhRMSPrEMMa41q7nqCyY80AcO8yOSzp7KkHoGn9ioi/xHkYvkH7jHIH+sFXdEeg8Oo+9oclU1aHl7B7e7giu45mwhs11nZyMhgotGJjluJY06BvqIUh8n7vjo6D+0j8G+nZxVFYeLQrxn3Z3dbzv76BjwcCGgURj2hYcp9QEeMcDDPrI0GJd3D1fi8HD1hVSN3giI67muQWhrJbh4FkxrnACwassxhIE/skMa9EQdU/8o4/bXXnoQNxNzyXAs6SLSh2UwMNdDrSQOWegEg9jSSr5vTTh7ddbHNeTQovtNK3BRdd0RdaPYd2PcSjvE2zWTXt88/+v51fzW7G+FQ6LZ3Tco8djfupvXsH1cmb3O7pko2KLgZq+b8K0Qn+HzO9ywtobvd1YSddSQ4fPfyFQ1TwUrYCqLgqdtY9f/k+zw3ONmB09Z3ZEevJQNh3mDG8SKm1PkgeOgB439V2lSM3OaEHOauOY0ueHTs29Or87j//6SfwDRc4oaBBQAAA==",
                                           "H4sIAAAAAAAA/8VY227bOBD9lYEWKFogkkhR18QRYLvpbrF2EsQtun2kJMrilpIMSontfP1SdpImiJdmgQLRk2CemTlz44w1kixvZQGbWjTduVX1/erUddfrtSPa3Fm2d+58fDP1sNsJXlt72Omm4y+ga+K0cul6CGH3n/lskVespjZvup42OVNSHT/tdj/O2pz2vG2OWYIDx4O2gsqic2sqc8XE3et8kBvEnE1XWOlIMFowmaLhyWkN4ClqXhh8BvADhEbuA2CUt00vW1FyJgro6fLcUi5Y6WK6mNhRFJHA80fuc9BhEWKlV9N2NjXBBlaKkyRBnhdiRBLiO5GJWGylUYICgjocRxGop6a38PNRngLKWLMEUB4rR02UJlbqZJiQKPC9ISwvJQra02dwjJAFvCmwet29eOcWqGB3t9kelbcFO7eolc6pZE3Viv7enty++2NDUHwm2vUJTJjsKwrqnNOTkfso+UpHbqWlZLyUysW7ttFBVbpxjJGN44Q4z3HuE/1XnkS/4EnTnAx8t/BlK5iEa0azttgeZYRCxSiOHA3Ot9Jeit9OeVFxKVlZnsBFzcUWxk3D4ELwe3o8jP4Qxsg0jOEBTuggp0+yfSiDjIkT+CQ5KyTPq2OMothTjALPlBHCT4xAHyXkIxwh3zdU7IWmiidt1+srNrPSGWPwjtarM1hUbKWutDMNXim9ZGv43sofR9ROHfjiwEcuBG+WFa2PtNhwkZhGliDTABBYmSr1/MCwgG5YzRve5UyNkw7a8mcJqbeWqapy9L5OtjBxhrsE/udyUqGTtOkE7VkB2RbmsnPgr1bSnMFwCzjwjfcVUOh+sF6ZVRz6ioHgJTvIZ9Cxb8DHhjQuYt801B+HiaPzevp1oe+wq+lMD7j8fq0HfKNXs0tjzxJDz5TZP02VBq/DdbiIZpOQRPoOcuYEhrYwtJ2osfxmtv3QMJjSVGMSGWqslnpXUGx7kZ0k+uqs9ZVFNcfMSm3NcWmlahPSAJbKOr3VACrlhGnYjIfOzcy4rp4ygfR19WJ9M+sXEhjSfb/baT8ECIdJEhpTx4bqi5gFRR4Wth/7pe2zLLYTLy9sir2A5gkJccn0ZYbJkR2Sio4Z8lZbxiPvWMNb1cVi8Te8fzFF2H653c0XBwxm1a7PP2jIo2HbVws3jvUR6PIua7Yr0y0yjozuDCPrKoPYSyKCSKzvo88NzHgmhx36a6fL6L9WOr6jXNBM6GArtWMQnxCU4CRU/9GwBttbqac53qgJuGKNBnGvZtFYcy5UV19Mx9dvmoDkbRKgCJKIEC/SJwC/aQLc/feN9D8b4j956BAAAA==",
                                           "H4sIAAAAAAAA/61X227jNhD9lQELFLuAI1GSZUmJI8A20u2izgXr3vaRkmiLrUQapBzb+fqO4mQ3F5dmgfpJEM+Mzpy50WPNS6Ur2LWNNJek7rr1ue9vt1uvUaW3Uvf+9eTLLAx804iWHGDnOyNeQbeRp/TKDykN/D+v54uy5i07E9J0TJYcrYw4N48v56pknVDy1JfgyHHvrWK6Mn7LdIlM/IPPJ7vezNuZiuTjhrOK65wGQTQsWQssRGphHH1mMIwpHftPgHGpZKdVsxS8qaBjq0uCIZB8MVtMz5IkieIwG/svQcdNIpLfztR85oKNSY5kKB2FWZAFQRh61MUsJXka0pQmJkizAPDXsg18/6FHoAWXK6hc3GUk94ogipJ4GMa7txYV69hL+JASELIKLgk8PoT9Qz42m+KAKlXFLwkj+c0tavD8+h2gPAWoeh3ndsDN1zs74A92O795CfG/hXMkssw1sq93nxydBvSbXIHd6TXTXNaq6R7Oppsff9hFNL1o1HYAU667mgGeCzawK7rUXCw11sK9kgO7MkEa0DMsn8hzjCQcxu8ioUcj+cJbIYUpOfa7AbWEn7TglRZljU+KF7wB3x5HsYcp00pyY2Dqwe9KwrM8r9WBC+g0k6ZhHa8Aza618eBnpVnJ0URKBGxFVwMD8zfvkAHS6WoOjVjy49TQyVUrmj0saqE1Xy6dBRq5dsZUmQ5DOreIUJB8zjngkEMefI2T7kTq+0kwgDJIk8SVcERdCUdxBmsPLuwUQgpl6/rx0ZHGOF5OmJinhGN6Bt8zdqrAkzTEAo9DZ0bxezmOM7qqNri5lDYWBg8k/8R1y+TeArrHWhBqpdm63rvSTP7DRJFy0DfOHn7dN1zDHWeFqvYnJwMdoXBp8v8zem6pwVOLTaTkcNWIB3Z6Wg37aeXMKaOJY22/Wn228m7tFJnlmJP8zHK8JDkuawtghV9nGwugJjm1HAtU0HULRrGjcB8erzkf01FC02Tk6B778dl9anGP8SwWv8CHV0uRH9ah1283D05vGQ/6ofjRogu2d5Lhig4j+yg2pSnkft24BpmMXDR0+joKHYRZEtHh0J7/zxLmotB9t/9muAX7F8kn90w0rGhssDWO/WgYRRSvpiO8/4YWbPemvt4c7/rOx0xW9nl5M7GcN3ivuJpN7v4tBf7hv0v+D9MPU7LEDAAA",
                                           "H4sIAAAAAAAA/61XbW/bNhD+K4QGDC1gS6RkmXLiCLCNtCvmpEG9YdtHSqItbhRpkHJs59fvFMdtXlyaBepPhPjc3XPv9NjwUpsK7Rqp7FVQt+36Ioq2220odRmu9H10M/kyi0lkpWiCA+xiZ8UL6DYJtVlFMcYk+vtmvihr3rC+ULZlquQgZcWFffw41yVrhVbnLKET1522ipnKRg0zJTCJDjqf5DqxcGerIB9LzipuckxINihZg1gM1GJKPzE0SDEeR0+AcalVa7RcCi4r1LLVVQAuBPlitpj2KaVJGpNx9Bx0WiQJ8s8zPZ/5YNMgBzIYD+MRGRESxyH2EcuCPEsJJnFLshElGaUN26BvP9CIcMHVClU+6kZBHhYkSWg6iOPBa4mKtew5fIADJFRFrgL0eIi7Qz62m+KAKnXFrwIW5JNbiMHx8xtAeQ4Aubv9584N+It9nt8+h0Rf2Z4gTo7EiZs4BM5htg7yFTfeRkee0QJfP3oqJRh7enLDDFe1lu1Df7r59ZddgrNLqbc9NOWmrRmCe8F67iwtDRdLA/V1r1XPnQ6SEdyHkkxCT0/iQfrGE3zSky+8EUrYksMMsUgv0QcjeGVEWcNJ84JLFLn9KPZoGnZOoGNUXgYFXaLWMGUla3mFAH1jbIh+04aVHESUAsBWtDViyP7HWzAMLNqaIymW/DQjUHLdCLlHi1oYw5dL77gMfZtsqm0LLl04fC+CfM45gnkJPPgahuaZjHdDpYfKbq74Ek6wL+EkHaF1iC7dFGKMysbXeOpt/IMwtkXrTSGFrSHLP+Li8ETXna5VSP9TWUER9L7VxbnuoVkM3ZPG3ozSt36fZnRdbWDVamMdDB6C/CM3DVN7B+geKk7olWHreu9Lk/7AuFKq17XnHv2xl9ygO84KXe3Pjh08hMBl9OczOjZu76mRJ0pxdC3FAzs/CgfdKPTmNMLUs4hf7GpXEzVuisxxzYO877henluSK7DONu4tih3XAiLou2KT1DNw7x7fZe9JPKQ4TYee+qEhj/ozh35waLH4Hb17sXL5Ydk+rp0Qnd9hIepK5r0jMNDfdAQPAJK6J74tbaH2a+nrJB36BNHLOkSaxCOaQGLcBfBJobkoTNfuf1ruwP4Lb8V7JiQrpAu2hu2SDJIEw2N6SOnQ1R7tqwJ7db3rWh8yWbkH5u3EcS/h1XI9m9x9LwXR4d9W/j8ZpK49dg0AAA=="
                                         ]))
    end
    it "when deduplication is on it displays a tabbed interface" do
      # visit 'catalog/a61f9a41-edeb-43db-a0bb-04f1cd360266/staff_view'
      allow(view).to receive(:params).and_return(id: "a61f9a41-edeb-43db-a0bb-04f1cd360266")
      allow(Flipflop).to receive(:deduplication?).and_return(true)

      render
      expect(rendered).to have_selector(
        'lux-tab[title="New York Public Library - ebook"]'
      )
    end
    it "when deduplication is off it does not display a tabbed interface" do
      # visit 'catalog/a61f9a41-edeb-43db-a0bb-04f1cd360266/staff_view'
      allow(view).to receive(:params).and_return(id: "a61f9a41-edeb-43db-a0bb-04f1cd360266")
      allow(Flipflop).to receive(:deduplication?).and_return(false)

      render
      expect(rendered).not_to have_selector(
        'lux-tab[title="New York Public Library - ebook"]'
      )
    end
  end
end
# rubocop:enable Layout/LineLength
