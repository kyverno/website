export const getPostColorFromCategory = (category) => {
  switch (category) {
    case 'Releases':
      return 'bg-primary-100 text-primary-25'
    case 'General':
      return 'bg-accent-100 text-accent-25'
  }
}
