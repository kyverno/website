import { BlogCard } from '../components/BlogCard'
import { Button } from '../components/Button'
import { HeadingContent } from '../components/HeadingContent'
import { BlogSectionContent } from '../constants'
import { getPostColorFromCategory } from '../utils/postUtils'

export const BlogSection = ({ latestPosts }) => {
  const { headingText, paragraphText } = BlogSectionContent

  return (
    <section className="py-20 px-6">
      <div className="container">
        <HeadingContent
          headingParts={headingText}
          subheading={paragraphText}
          variant="level2"
          headerLevel="h2"
        />
        <div className="flex flex-col items-center space-y-4 mt-16 md:flex-row md:flex-wrap md:items-stretch md:justify-center space-x-4">
          {latestPosts.map(
            ({ data: { title, description, category } }, postIndex) => (
              <BlogCard
                color={getPostColorFromCategory(category)}
                key={postIndex}
                title={title}
                description={description}
                category={category}
              />
            ),
          )}
        </div>
        <div className="flex justify-center mt-10">
          <Button href="/blog" variant="accent" size="large">
            Read The Blog
          </Button>
        </div>
      </div>
    </section>
  )
}
