import { Tag } from '../components/Tag'
import { Button } from '../components/Button'

export const BlogHeroSection = ({ postTitle, postDescription, slug }) => {
  return (
    <section className="w-full bg-linear-to-br from-dark-50 to-dark-100 relative py-10 px-4 sm:p-20 overflow-x-clip">
      <div className="container">
        <div className="max-w-3xl mx-auto text-center flex flex-col justify-center items-center space-y-6">
          <Tag variant="tertiary" className="max-w-40">
            Latest Post
          </Tag>
          <h1 className="font-bold text-4xl text-center md:text-6xl capitalize leading-12 sm:leading-16 tracking-wide">
            {postTitle}
          </h1>
          <p className="text-center text-xl text-white/80 max-w-xl mx-auto">
            {postDescription}
          </p>
          <div className="flex justify-center">
            <Button href={`/blog/${slug}`} variant="primary" size="large">
              Read more
            </Button>
          </div>
        </div>
      </div>
    </section>
  )
}
