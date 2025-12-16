import { twMerge } from 'tailwind-merge'
import { Button } from './Button'

export const BlogCard = ({ color, title, description, category, slug }) => {
  function truncateText(str, maxLength) {
    if (str.length > maxLength) {
      return str.slice(0, maxLength - 3) + '...' // Leave space for "..."
    }
    return str
  }

  return (
    <div className="relative z-0 p-8 md:p-10 max-w-xs lg:min-w-md group">
      <div
        className={twMerge(
          'absolute size-16 rounded-xl bg-primary-100 top-1.5 right-1.5 -z-10',
          color,
        )}
      ></div>
      <div className="absolute inset-0 bg-dark-50 -z-10 rounded-2xl [mask-image:linear-gradient(225deg,transparent,transparent_40px,black_40px)]"></div>
      <div
        className={twMerge(
          'px-3 py-1.5 uppercase font-heading rounded-full inline-flex font-extrabold tracking-wider text-xs',
          color,
        )}
      >
        {category}
      </div>
      <h3 className="font-black text-3xl mt-12">{truncateText(title, 32)}</h3>
      <p className="text-lg text-white/70 mt-4">
        {truncateText(description, 90)}
      </p>
      <div className="min-w-full flex justify-between mt-12">
        <Button
          href={`/blog/${slug}`}
          variant="tertiary"
          size="small"
          className={`${color} m-0`}
        >
          Read more
        </Button>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={2}
          stroke="currentColor"
          className="size-8"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M17.25 8.25 21 12m0 0-3.75 3.75M21 12H3"
          />
        </svg>
      </div>
    </div>
  )
}
