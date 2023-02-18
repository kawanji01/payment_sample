module ApplicationHelper

  def default_meta_tags
    {
      site: 'Sample',
      title: t('layouts.title'),
      reverse: true,
      charset: 'utf-8',
      description: t('layouts.description'),
      keywords: t('layouts.keywords'),
      canonical: request.original_url,
      separator: '|',
      icon: [
        { href: image_url('taflingual_icon.jpg') },
        { href: image_url('taflingual_icon.jpg'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/jpg' }
      ],
      og: {
        site_name: :site,
        title: :title,
        description: :description,
        type: 'website',
        url: request.original_url,
        image: image_url(''),
        locale: @locale
      },
      twitter: {
        card: 'summary',
        site: '@Sample'
      }
    }
  end


end
