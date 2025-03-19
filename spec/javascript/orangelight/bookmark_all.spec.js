import BookmarkAllManager from '../../../app/javascript/orangelight/bookmark_all.es6';
describe('BookmarkAllManager', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div id="content" class="col-12 col-md-8">
        <div id="sortAndPerPage" class="clearfix">
          <div class="search-widgets float-end">
            <div class="btn-group">
              <button class="btn btn-default checkbox bookmark_all">
                <label for="bookmark_all_input">
                  <input type="checkbox" id="bookmark_all_input">
                  <span>Bookmark all</span>
                </label>
              </button>
            </div>
          </div>
        </div>
        <h2 class="visually-hidden visually-hidden">Search Results</h2>
        <div id="documents" class="documents-list">
          <article data-document-id="99122304923506421" data-document-counter="1" itemscope="itemscope" itemtype="http://schema.org/Thing" class="blacklight-book document document-position-1">
            <div class="row search-result-wrapper">
              <div class="record-wrapper">
                <header class="documentHeader">
                  <h3 class="index_title document-title-heading col">
                  <span class="document-counter">1. </span><a data-context-href="/catalog/99122304923506421/track?counter=1&amp;document_id=99122304923506421&amp;per_page=20&amp;search_id=111" data-context-method="post" data-turbo-prefetch="false" itemprop="name" dir="ltr" href="/catalog/99122304923506421">Ahmet Kutsi Tecer sempozyum bildirileri : Sıvas 24 - 27 Nisan 2018 / editör Teoman Karaca.</a></h3>
                </header>
                <ul class="document-metadata dl-horizontal dl-invert">
                  <li><ul><li><a class="search-name" data-original-title="Search: Ahmet Kutsi Tecer Sempozyumu (2018 : Sivas, Turkey)" href="/?f[author_s][]=Ahmet+Kutsi+Tecer+Sempozyumu+%282018+%3A+Sivas%2C+Turkey%29">Ahmet Kutsi Tecer Sempozyumu (2018 : Sivas, Turkey)</a> <a class="browse-name" data-original-title="Browse: Ahmet Kutsi Tecer Sempozyumu (2018 : Sivas, Turkey)" dir="ltr" href="/browse/names?q=Ahmet+Kutsi+Tecer+Sempozyumu+%282018+%3A+Sivas%2C+Turkey%29">[Browse]</a></li></ul></li>
                  <li><ul><li>Sıvas : Sıvas İl Kültür Turizm Müdürlüğü, [2019]</li></ul></li>
                  <li><ul><li><ul><li class="blacklight-format" dir="ltr"> <span class="icon icon-book" aria-hidden="true"></span> Book </li></ul></li></ul></li>
                </ul>
              </div>
              <div class="thumbnail-wrapper">
              <form class="bookmark-toggle" data-present="In Bookmarks" data-absent="Bookmark" data-inprogress="Saving..." action="/bookmarks/99127972072106421" accept-charset="UTF-8" method="post">
                <input type="hidden" name="_method" value="put" autocomplete="off">
                <div class="checkbox toggle-bookmark">
                  <label class="toggle-bookmark" data-checkboxsubmit-target="label">
                    <input type="checkbox" class="toggle-bookmark " data-checkboxsubmit-target="checkbox">
                    <span data-checkboxsubmit-target="span">Bookmark</span>
                  </label>
                </div>
                <input type="submit" name="commit" value="Bookmark" class="bookmark-add btn btn-outline-secondary" data-disable-with="Bookmark">
              </form>
              </div>
            </div>
          </article>
          <article data-document-id="99127972072106421" data-document-counter="2" itemscope="itemscope" itemtype="http://schema.org/Thing" class="blacklight-book document document-position-2">
            <div class="row search-result-wrapper">
              <div class="record-wrapper">
                <header class="documentHeader">
                  <h3 class="index_title document-title-heading col">
                  <span class="document-counter">2. </span><a data-context-href="/catalog/99127972072106421/track?counter=2&amp;document_id=99127972072106421&amp;per_page=20&amp;search_id=111" data-context-method="post" data-turbo-prefetch="false" itemprop="name" dir="ltr" href="/catalog/99127972072106421">Dancing Black, dancing White : rock 'n' roll, race, and youth culture of the 1950s and early 1960s / Julie Malnig.</a></h3>
                </header>
                <ul class="document-metadata dl-horizontal dl-invert">
                  <li><ul><li><a class="search-name" data-original-title="Search: Malnig, Julie" href="/?f[author_s][]=Malnig%2C+Julie">Malnig, Julie</a> <a class="browse-name" data-original-title="Browse: Malnig, Julie" dir="ltr" href="/browse/names?q=Malnig%2C+Julie">[Browse]</a></li></ul></li>
                  <li><ul><li>New York, NY : Oxford University Press, [2023]</li></ul></li>
                  <li><ul><li><ul><li class="blacklight-format" dir="ltr"> <span class="icon icon-book" aria-hidden="true"></span> Book </li></ul></li></ul></li>
                </ul>
              </div>
              <div class="thumbnail-wrapper">
                <form class="bookmark-toggle" data-present="In Bookmarks" data-absent="Bookmark" data-inprogress="Saving..." action="/bookmarks/99127972072106421" accept-charset="UTF-8" method="post">
                  <input type="hidden" name="_method" value="put" autocomplete="off">
                  <div class="checkbox toggle-bookmark">
                    <label class="toggle-bookmark" data-checkboxsubmit-target="label">
                      <input type="checkbox" class="toggle-bookmark " data-checkbox submit-target="checkbox">
                      <span data-checkboxsubmit-target="span">Bookmark</span>
                    </label>
                  </div>
                  <input type="submit" name="commit" value="Bookmark" class="bookmark-add btn btn-outline-secondary" data-disable-with="Bookmark">
                </form>
              </div>
            </div>
          </article>
          <article data-document-id="99125476820706421" data-document-counter="3" itemscope="itemscope" itemtype="http://schema.org/Thing" class="blacklight-book document document-position-3">
            <div class="row search-result-wrapper">
              <div class="record-wrapper">
                <header class="documentHeader">
                  <h3 class="index_title document-title-heading col">
                  <span class="document-counter">3. </span><a data-context-href="/catalog/99125476820706421/track?counter=3&amp;document_id=99125476820706421&amp;per_page=20&amp;search_id=111" data-context-method="post" data-turbo-prefetch="false" itemprop="name" dir="ltr" href="/catalog/99125476820706421">Black youth aspirations : imagined futures and transitions into adulthood / by Botshabelo Maja (Independent Scholar, Republic of South Africa).</a></h3>
                </header>
                <ul class="document-metadata dl-horizontal dl-invert">
                  <li><ul><li><a class="search-name" data-original-title="Search: Maja, Botshabelo" href="/?f[author_s][]=Maja%2C+Botshabelo">Maja, Botshabelo</a> <a class="browse-name" data-original-title="Browse: Maja, Botshabelo" dir="ltr" href="/browse/names?q=Maja%2C+Botshabelo">[Browse]</a></li></ul></li>
                  <li><ul><li><ul id="pub_created_display-list"><li class="blacklight-pub_created_display" dir="ltr">United Kingdom : Emerald Publishing Limited, 2022.</li><li class="blacklight-pub_created_display" dir="ltr">©2022</li></ul></li></ul></li>
                  <li><ul><li><ul><li class="blacklight-format" dir="ltr"> <span class="icon icon-book" aria-hidden="true"></span> Book </li></ul></li></ul></li>
                </ul>
              </div>
              <div class="thumbnail-wrapper">
                <form class="bookmark-toggle" data-present="In Bookmarks" data-absent="Bookmark" data-inprogress="Saving..." action="/bookmarks/99125476820706421" accept-charset="UTF-8" method="post">
                  <input type="hidden" name="_method" value="put" autocomplete="off">
                  <div class="checkbox toggle-bookmark">
                    <label class="toggle-bookmark" data-checkboxsubmit-target="label">
                      <input type="checkbox" class="toggle-bookmark " data-checkboxsubmit-target="checkbox">
                      <span data-checkboxsubmit-target="span">Bookmark</span>
                    </label>
                  </div>
                  <input type="submit" name="commit" value="Bookmark" class="bookmark-add btn btn-outline-secondary" data-disable-with="Bookmark">
                </form>
              </div>
            </div>
          </article>
        </div>
      </div>`;
    new BookmarkAllManager();
  });
  describe('Use keyboard on bookmark all button', () => {
    it('Selects all the bookmark checkboxes using space or enter', () => {
      // Space and enter generate a click event in the browser
      const bookmark_all_button = document.querySelector('.bookmark_all');
      const bookmark_all_input = document.querySelector('#bookmark_all_input');

      expect(bookmark_all_input.checked).toBe(false);
      let bookmark_checkboxes = document.querySelectorAll(
        'input.toggle-bookmark:not(:checked)'
      );
      expect(bookmark_checkboxes.length).toBe(3);
      bookmark_all_button.click();
      bookmark_checkboxes = document.querySelectorAll(
        'input.toggle-bookmark:checked'
      );
      expect(bookmark_checkboxes.length).toBe(3);
      bookmark_all_button.click();
      bookmark_checkboxes = document.querySelectorAll(
        'input.toggle-bookmark:not(:checked)'
      );
      expect(bookmark_checkboxes.length).toBe(3);
    });
  });
});
