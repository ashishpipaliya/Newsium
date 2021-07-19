const default_limit = 10;

const getNewsEndpoint = (news_type) => {
  if (
    news_type == "all_news" ||
    news_type == "trending" ||
    news_type == "top_stories"
  )return `https://inshorts.com/api/en/news?category=${news_type}&max_limit=${ default_limit
      }&include_card_data=true`;
    

  return `https://inshorts.com/api/en/search/trending_topics/${news_type}&max_limit=${ default_limit
    }&type=NEWS_CATEGORY`;
};



module.exports = getNewsEndpoint;