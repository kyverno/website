import { Star, X } from 'lucide-react'

export const TopBanner = ({ onClose }) => {
  return (
    <div className="text-sm w-full top-0 bg-primary-75 text-black flex justify-center items-center p-2 space-x-3 md:space-x-6 md:text-lg">
      <div className="flex justify-center items-center space-x-2">
        <Star className="fill-amber-400 stroke-1 stroke-gray-800" />
        <span>
          <a
            href="https://github.com/kyverno/kyverno/"
            className="font-bold text-center"
          >
            Like Kyverno? Star on Github to follow and support
          </a>
        </span>
        <Star className="fill-amber-400 stroke-1 stroke-gray-800" />
      </div>
      <button
        onClick={onClose}
        className="border border-dark-50 cursor-pointer flex justify-center items-center"
      >
        <X className="w-5 h-5 text-black" />
      </button>
    </div>
  )
}
